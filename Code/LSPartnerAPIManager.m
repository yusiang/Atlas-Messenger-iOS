//
//  LSJiraManager.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/23/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSPartnerAPIManager.h"
#import "LSHTTPResponseSerializer.h"
#import <MessageUI/MessageUI.h> 

#define kJMCHeaderNameRequestId @"-x-jmc-requestid"

typedef NS_ENUM(NSUInteger, LSJiraAttachmentType) {
    LSAttachmentTypeRecording = 1,
    LSAttachmentTypeImage = 2,
    LSAttachmentTypePayload = 3, // use this type for any custom attachments.
    LSAttachmentTypeCustom = 4,  // used for any custom fields
    LSAttachmentTypeSystem = 5
};

NSString *const LSAttachmentDirectoryPath = @"com.layer.sample";

@interface LSJiraAttachmentItem : NSObject

@property(nonatomic) NSString *contentType;
@property(nonatomic) NSUInteger dataLength;
@property(nonatomic) NSString *path;
@property(nonatomic) BOOL deleteFileWhenSent;

@property(nonatomic) NSData *data;
@property(nonatomic) NSString *name;
@property(nonatomic) NSString *filenameFormat;
@property(nonatomic) UIImage *thumbnail;
@property(nonatomic) LSJiraAttachmentType type;

@end

@implementation LSJiraAttachmentItem

+ (instancetype)attachmentWithName:(NSString *)name
                              data:(NSData *)data
                              type:(LSJiraAttachmentType)attachmentType
                       contentType:(NSString *)contentType
                    filenameFormat:(NSString *)filenameFormat
{
    return [[self alloc] initWithName:name data:data type:attachmentType contentType:contentType filenameFormat:filenameFormat];
}
- (id)initWithName:(NSString *)name
              data:(NSData *)data
              type:(LSJiraAttachmentType)attachmentType
       contentType:(NSString *)contentType
    filenameFormat:(NSString *)filenameFormat
{
    self = [super init];
    if (self) {
        _contentType = contentType;
        _data = data;
        _filenameFormat = filenameFormat;
        _name = name;
        _type = attachmentType;
        [self saveDataToFile:[self attachmentDirPath]];
    }
    return self;
}

- (NSString *)attachmentDirPath
{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSString* attachmentDir = [LSAttachmentDirectoryPath stringByAppendingPathComponent:@"attachments"];
    
    NSString* file = [attachmentDir stringByAppendingPathComponent:[self.name stringByAppendingFormat:@"-%@", uuid]];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:attachmentDir]) {
        [fileManager createDirectoryAtPath:attachmentDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return file;
}

- (void)saveDataToFile:(NSString*)file
{
    BOOL success = [self.data writeToFile:file atomically:NO];
    if (success)
    {
        self.path = file;
        self.dataLength = [self.data length];
    }
}

@end

@interface LSJiraRequestItem : NSObject <MFMailComposeViewControllerDelegate>

@property (nonatomic) NSString *uuid;
@property (nonatomic) NSArray* attachments;
@property (nonatomic) NSString* type;
@property (nonatomic) NSString* originalIssueKey;

@end

@implementation LSJiraRequestItem

+ (instancetype)itemWithUUID:(NSString *)UUID type:(NSString*)type attachments:(NSArray*)attachments issueKey:(NSString *)originalIssueKey
{
    return [[self alloc] initWithUUID:UUID type:type attachments:attachments issueKey:originalIssueKey];
}

-(id)initWithUUID:(NSString*)uuid type:(NSString*)type attachments:(NSArray*)attachments issueKey:(NSString *)originalIssueKey
{
    if ((self = [super init])) {
        self.uuid = uuid;
        self.type = type;
        self.attachments = attachments;
        self.originalIssueKey = originalIssueKey;
    }
    return self;
}

@end

@interface LSPartnerAPIManager () <NSURLSessionDelegate>

@property (nonatomic) NSURL *baseURL;
@property (nonatomic) NSURLSession *URLSession;
@property (nonatomic) NSURLSession *uploadSession;

@end

@implementation LSPartnerAPIManager

+ (instancetype)managerWithBaseURL:(NSURL *)baseURL
{
    return [[self alloc] initWithBaseURL:baseURL];
}

- (id)initWithBaseURL:(NSURL *)baseURL
{
    self = [super init];
    if (self) {
        _baseURL = baseURL;
        _URLSession = [self defaultURLSession];
        _uploadSession = [self uploadSession];
    }
    return self;
}

- (NSURLSession *)uploadSession
{
    NSData *nsdata = [@"kevin:kfc1coleman" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedCreds = [nsdata base64EncodedStringWithOptions:0];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{ @"Accept": @"application/json",
                                             @"Authorization": [NSString stringWithFormat:@"Basic %@", base64EncodedCreds]};
    return [NSURLSession sessionWithConfiguration:configuration];
}

- (NSURLSession *)defaultURLSession
{
    NSData *nsdata = [@"kevin:kfc1coleman" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedCreds = [nsdata base64EncodedStringWithOptions:0];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{ @"Accept": @"application/json",
                                             @"Content-Type": @"application/json",
                                             @"Authorization": [NSString stringWithFormat:@"Basic %@", base64EncodedCreds]};
    return [NSURLSession sessionWithConfiguration:configuration];
}


- (void)postIssueWithPhoto:(UIImage *)photo summary:(NSString *)summary description:(NSString *)description
{
    // Email Subject
    NSString *emailTitle = @"Test Email";
    // Email Content
    NSString *messageBody = @"iOS programming is so fun!";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"support@appcoda.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    

}
//
//- (void)postIssueWithPhoto:(UIImage *)photo summary:(NSString *)summary description:(NSString *)description
//    {
//    
//    NSDictionary *parameters = @{@"fields":
//                                    @{@"project":
//                                         @{@"key": @"DES"},
//                                      @"summary": summary,
//                                      @"description": description,
//                                      @"issuetype":
//                                          @{@"name": @"Bug" }}};
//    NSURL *URL = [NSURL URLWithString:@"rest/api/2/issue/" relativeToURL:self.baseURL];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
//    request.HTTPMethod = @"POST";
//    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
//
//    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        
//        NSLog(@"Got response: %@, data: %@, error: %@", response, data, error);
//        if (!response && error) {
//            NSLog(@"Failed with error: %@", error);
//            return;
//        }
//        
//        NSError *serializationError = nil;
//        NSDictionary *userDetails = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
//        BOOL success = [LSHTTPResponseSerializer responseObject:&userDetails withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
//        if (success) {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self attachImage:photo toIssue:[userDetails valueForKey:@"key"]];
//            });
//        } else {
//         
//        }
//    }] resume];
//}
//
//
//#define kTypeCreate @"CREATE"
//
//- (void)attachImage:(UIImage *)image toIssue:(NSString *)issueKey
//{
//    LSJiraAttachmentItem *attachment = [LSJiraAttachmentItem attachmentWithName:@"image" data:UIImagePNGRepresentation(image) type:LSAttachmentTypeImage contentType:@"image/png" filenameFormat:@"image-%d.png"];
//    LSJiraRequestItem *item = [LSJiraRequestItem itemWithUUID:[[NSUUID UUID] UUIDString] type:kTypeCreate attachments:@[attachment] issueKey:issueKey];
//    NSString *issueURL = [NSString stringWithFormat:@"rest/api/2/issue/%@/attachments", issueKey];
//    NSURL *URL = [NSURL URLWithString:issueURL relativeToURL:self.baseURL];
//    NSMutableURLRequest *request = [self requestWithRequestItem:item URL:URL];
//
//    
//    [[self.uploadSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        
//        NSLog(@"Got response: %@, data: %@, error: %@", response, data, error);
//        if (!response && error) {
//            NSLog(@"Failed with error: %@", error);
//            return;
//        }
//        
//        NSError *serializationError = nil;
//        NSDictionary *userDetails = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
//        BOOL success = [LSHTTPResponseSerializer responseObject:&userDetails withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
//        if (success) {
//            
//        } else {
//            
//        }
//    }] resume];
//}
//
//
//- (NSMutableURLRequest *)requestWithRequestItem:(LSJiraRequestItem *)item URL:(NSURL *)URL
//{
//    // Bounday for multi-part upload
//    static NSString *boundary = @"JMCf06ddca8d02e6810c0a7e3e9e9086da87f07080f";
//    
//    // Create request
//    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
//    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
//    [request setValue:item.uuid forHTTPHeaderField:kJMCHeaderNameRequestId];
//    [request setValue:@"nocheck" forHTTPHeaderField:@"X-Atlassian-Token"];
//    [request setHTTPBody:[self multiPartDataWithImage:[UIImage imageNamed:@"back"] url:URL item:item.attachments[0]]];
//    
//    //[self addAttachments:item.attachments toRequest:request boundary:boundary uuid:item.uuid];
//
//    return request;
//}
//
//// Create a Class for this ...perhaps LSTransport
//- (void)addAttachments:(NSArray *)attachments toRequest:(NSMutableURLRequest *)request boundary:(NSString *)boundary uuid:(NSString*)uuid
//{
//    
//    // the path to write the POST body to before sending
//    NSString* postDataFilePath = [self filePathForUUID:uuid];
//    NSFileManager* fileManager = [NSFileManager defaultManager];
//    // if this file already exists, simply use it, else, create it and write out the POST request to it
//    if (![[NSFileManager defaultManager] fileExistsAtPath:postDataFilePath])
//    {
//        [self writeMultiPartRequest:attachments boundary:boundary toFile:postDataFilePath];
//        // delete all the parts from disk that can be deleted. this POST body file will now be used instead.
////        for (LSJiraAttachmentItem *item in attachments)
////        {
////            // Delete the file from the Path if necessary
////        }
//    }
//    
//    NSInputStream* inStream = [[NSInputStream alloc] initWithFileAtPath:postDataFilePath];
//    
//    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:postDataFilePath error:nil];
//    
//    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
//    NSString* fileSize = [fileSizeNumber stringValue];
//    [request addValue:fileSize forHTTPHeaderField:@"Content-Length"];
//    [request setHTTPBodyStream:inStream];
//}
//
//- (NSString *)filePathForUUID:(NSString *)UUID
//{
//    return [LSAttachmentDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.POST-REQUEST", UUID]];
//}
//
//- (void)writeMultiPartRequest:(NSArray*)parts boundary:(NSString*)boundary toFile:(NSString*)path
//{
//    
//    NSOutputStream* stream = [[NSOutputStream alloc] initToFileAtPath:path append:NO];
//    [stream open];
//    NSMutableDictionary *unique = [[NSMutableDictionary alloc] init];
//    
//    // Ignore for now
//    NSInteger attachmentIndex = 0;
//    for (u_int i = 0; i < [parts count]; i++) {
//        LSJiraAttachmentItem *item = [parts objectAtIndex:i];
//        if (item != nil && item.filenameFormat != nil) {
//            
//            NSString *filename = [NSString stringWithFormat:item.filenameFormat, attachmentIndex];
//            NSString *key = [item.name stringByAppendingFormat:@"-%ld", (long)attachmentIndex];
//            if (item.type == LSAttachmentTypeCustom ||
//                item.type == LSAttachmentTypeSystem) {
//                // the JIRA Plugin expects all customfields to be in the 'customfields' part.
//                // If this changes, plugin must change too
//                [unique setValue:item forKey:item.name];
//            } else {
//                [self addPart:item filename:filename key:key boundary:boundary toStream:stream];
//                attachmentIndex++;
//            }
//        }
//    }
//    
//    for (NSString *key in unique) {
//        LSJiraAttachmentItem *item = [unique valueForKey:key];
//        NSString *filename = [NSString stringWithFormat:item.filenameFormat, attachmentIndex];
//        
//        [self addPart:item filename:filename key:item.name boundary:boundary toStream:stream];
//        
//        attachmentIndex++;
//    }
//    
//    NSData* eof = [[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
//    [stream write:[eof bytes] maxLength:[eof length]];
//    [stream close];
//}
//
//- (void)addPart:(LSJiraAttachmentItem *)item
//      filename:(NSString *)filename
//           key:(NSString *)key
//      boundary:(NSString *)boundary
//      toStream:(NSOutputStream *)stream
//{
//    NSMutableData *body = [NSMutableData dataWithCapacity:0];
//    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, filename] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", item.contentType] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [stream write:[body bytes] maxLength:[body length]];
//    if (item.data)
//    {
//        [stream write:[item.data bytes] maxLength:[item.data length]];
//    }
//    else
//    {
//        [self appendPostDataToStream:stream fromFile:item.path];
//    }
//    NSData* eol = [[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding];
//    [stream write:[eol bytes] maxLength:[eol length]];
//}
//
//- (void)appendPostDataToStream:(NSOutputStream*)outStream fromFile:(NSString *)file
//{
//    NSInputStream *inStream = [[NSInputStream alloc] initWithFileAtPath:file];
//    [inStream open];
//    NSUInteger bytesRead;
//    while ([inStream hasBytesAvailable]) {
//        
//        unsigned char buffer[1024*256];
//        bytesRead = [inStream read:buffer maxLength:sizeof(buffer)];
//        if (bytesRead == 0) {
//            break;
//        }
//        
//        [outStream write:buffer maxLength:bytesRead];
//    }
//    [inStream close];
//}
//
//- (NSMutableData *)multiPartDataWithImage:(UIImage *)image url:(NSURL *)URL item:(LSJiraAttachmentItem *)item
//{
//    NSString *boundary = @"JMCf06ddca8d02e6810c0a7e3e9e9086da87f07080f";
//    NSString *filename = @"image.png";
//    
//    NSMutableData *body = [NSMutableData dataWithCapacity:0];
//    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", item.name, filename] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", item.contentType] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:UIImagePNGRepresentation(image)];
//    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//   
//    return body;
//}
//
////- (NSMutableURLRequest *)photoBodyWithImage:(UIImage *)image url:(NSURL *)URL
////{
////    NSString *boundary = @"---------------------------14737809831466499882746641449";
////    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
////    
////    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
////    [request setHTTPMethod:@"POST"];
////    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
////    
////    NSMutableData *postbody = [NSMutableData data];
////    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
////    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
////    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\nContent-Transfer-Encoding: binary\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
////    [postbody appendData:UIImagePNGRepresentation(image)];
////    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
////    [request setHTTPBody:postbody];
////    return request;
////}
@end

