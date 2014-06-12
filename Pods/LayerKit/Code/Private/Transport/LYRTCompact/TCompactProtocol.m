/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

#import "TCompactProtocol.h"
#import "TProtocolException.h"
#import "TObjective-C.h"

static __unused uint8_t THRIFT_COMPACT_PROTOCOL_ID = 0x82;
static __unused int8_t THRIFT_COMPACT_VERSION = 0x01;
static __unused uint8_t THRIFT_COMPACT_VERSION_MASK = 0x1f;
static __unused uint8_t THRIFT_COMPACT_TYPE_MASK = 0xe0;
static __unused uint8_t THIRFT_COMPACT_TYPE_SHIFT_AMOUNT = 5;

typedef NS_ENUM(uint8_t, TCompactType) {
    TCompactType_BOOLEAN_TRUE = 0x01,
    TCompactType_BOOLEAN_FALSE = 0x02,
    TCompactType_BYTE = 0x03,
    TCompactType_I16 = 0x04,
    TCompactType_I32 = 0x05,
    TCompactType_I64 = 0x06,
    TCompactType_DOUBLE = 0x07,
    TCompactType_BINARY = 0x08,
    TCompactType_LIST = 0x09,
    TCompactType_SET = 0x0A,
    TCompactType_MAP = 0x0B,
    TCompactType_STRUCT = 0x0C
};

static TCompactProtocolFactory * gSharedFactory = nil;

@implementation TCompactProtocolFactory

+ (TCompactProtocolFactory *)sharedFactory {
    if (gSharedFactory == nil) {
        gSharedFactory = [[TCompactProtocolFactory alloc] init];
    }
    
    return gSharedFactory;
}

- (TCompactProtocol *)newProtocolOnTransport:(id<TTransport>)transport {
    return [[TCompactProtocol alloc] initWithTransport:transport];
}

@end

@implementation TCompactProtocol

- (id)initWithTransport:(id<TTransport>)transport {
    return [self initWithTransport:transport strictRead:NO strictWrite:YES];
}

- (id)initWithTransport:(id<TTransport>)transport strictRead:(BOOL)strictRead strictWrite:(BOOL)strictWrite {
    if (self = [super init]) {
        mTransport = [transport retain_stub];
        mStrictRead = strictRead;
        mStrictWrite = strictWrite;
        _lastField = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)dealloc {
    [mTransport release_stub];
    [super dealloc_stub];
}

- (id <TTransport>)transport {
    return mTransport;
}

- (int32_t)messageSizeLimit {
    return mMessageSizeLimit;
}

- (void)setMessageSizeLimit:(int32_t)sizeLimit {
    mMessageSizeLimit = sizeLimit;
}

#pragma mark TProtocol

- (NSString *)readStringBody:(int)size
{
    char * buffer = malloc(size+1);
    
    if (!buffer) {
        @throw [TProtocolException exceptionWithName: @"TProtocolException"
                                              reason: [NSString stringWithFormat: @"Unable to allocate memory in %s, size: %i",
                                                       __PRETTY_FUNCTION__,
                                                       size]];;
    }
    
    [mTransport readAll: (uint8_t *) buffer offset: 0 length: size];
    
    buffer[size] = 0;
    
    NSString * result = [NSString stringWithUTF8String: buffer];
    
    free(buffer);
    
    return result;
}

- (void)readMessageBeginReturningName:(NSString **)name
                                 type:(int *)type
                           sequenceID:(int *)sequenceID
{
    uint8_t protocolId = [self readByte];
    if (protocolId != THRIFT_COMPACT_PROTOCOL_ID) {
        @throw [TProtocolException exceptionWithName: @"TProtocolException"
                                              reason: [NSString stringWithFormat:@"Bad protocol ID in readMessageBegin - got %d, expected %d", protocolId, THRIFT_COMPACT_PROTOCOL_ID]];
    }
    
    uint8_t versionAndType = [self readByte];
    uint8_t version = (uint8_t)(versionAndType & THRIFT_COMPACT_VERSION_MASK);
    if (version != THRIFT_COMPACT_VERSION) {
        @throw [TProtocolException exceptionWithName: @"TProtocolException"
                                              reason: [NSString stringWithFormat:@"Bad version in readMessageBegin - got %d, expected %d", version, THRIFT_COMPACT_VERSION]];
    }
    
    if (type != NULL) {
        *type = ((versionAndType >> THIRFT_COMPACT_TYPE_SHIFT_AMOUNT) & 0x03);
    }
    
    int seqId = [self readVarint32];
    if (sequenceID != NULL) {
        *sequenceID = seqId;
    }
    
    NSString *messageName = [self readString];
    if (name != nil) {
        *name = messageName;
    }
    
    return;
}

- (void)readMessageEnd {}

- (void)readStructBeginReturningName:(NSString **)name
{
    if (name != NULL) {
        *name = @"";
    }
    
    [_lastField addObject:@(_lastFieldId)];
    _lastFieldId = 0;
}

- (void)readStructEnd
{
    _lastFieldId = [((NSNumber *)[_lastField lastObject]) integerValue];
    [_lastField removeLastObject];
}

- (void)readFieldBeginReturningName:(NSString **)name
                               type:(int *)fieldType
                            fieldID:(int *)fieldID
{
    if (name != NULL) {
        *name = nil;
    }
    
    int ft = [self readByte];
    
    if (ft != TType_STOP) {
        short fID;
        // Mask off the 4 MSB of the type header, containing the field ID delta
        short modifier = (short)((ft & 0xf0)>> 4);
        if (modifier == 0) {
            // Not a delta, look ahead for the zigzag variant field ID
            fID = [self readI16];
        } else {
            // Has a delta, add the delta to the last read field ID
            fID = (short)(_lastFieldId + modifier);
        }
        
        uint8_t realType = [self getTType:(ft & 0x0f)];

        // if this happens to be a boolean field, the value is encoded in the type
        if ([self isBoolType:realType]) {
            // save the boolean value in a special instance variable.
            _boolValue = (uint8_t)(ft & 0x0f) == TCompactType_BOOLEAN_TRUE ? @(YES) : @(NO);
        }
        if (fieldType != NULL) {
            *fieldType = realType;
        }
        
        if (fieldID != NULL) {
            *fieldID = fID;
        }
        _lastFieldId = fID;
    } else {
        if (fieldType != NULL) {
            *fieldType = ft;
        }
    }
}

- (void) readFieldEnd {}

- (NSString *)readString
{
    int size = [self readVarint32];
    return [self readStringBody: size];
}

- (BOOL)readBool
{
    if (_boolValue != nil) {
        BOOL result = _boolValue.boolValue;
        _boolValue = nil;
        return result;
    }
    
    return [self readByte] == 1;
}

- (uint8_t)readByte
{
    uint8_t myByte;
    [mTransport readAll: &myByte offset: 0 length: 1];
    return myByte;
}

- (short)readI16
{
    return (short)[self zigzagToInt:[self readVarint32]];
}

- (int)readI32
{
    return [self zigzagToInt:[self readVarint32]];
}

- (int64_t)readI64;
{
    return [self zigzagToI64:[self readVarint64]];
}

- (double)readDouble;
{
    double value = 0;
    
    [mTransport readAll:(uint8_t *)&value offset:0 length:sizeof(int64_t)];
    
    return value;
}

- (NSData *)readBinary
{
    int32_t size = [self readVarint32];
    uint8_t * buff = malloc(size);
    if (buff == NULL) {
        @throw [TProtocolException
                exceptionWithName: @"TProtocolException"
                reason: [NSString stringWithFormat: @"Out of memory.  Unable to allocate %d bytes trying to read binary data.",
                         size]];
    }
    
    [mTransport readAll:buff offset:0 length:size];
    return [NSData dataWithBytesNoCopy:buff length:size];
}

- (void)readMapBeginReturningKeyType:(int *)keyType
                           valueType:(int *)valueType
                                size:(int *)size
{
    uint32_t readSize = [self readVarint32];
    uint8_t keyAndValueType = readSize == 0 ? 0 : [self readByte];
    uint8_t key = [self getTType:(uint8_t)(keyAndValueType >> 4)];
    uint8_t value = [self getTType:(uint8_t)(keyAndValueType & 0x0f)];

    if (keyType != NULL) {
        *keyType = key;
    }
    if (valueType != NULL) {
        *valueType = value;
    }
    if (size != NULL) {
        *size = readSize;
    }
}

- (void)readMapEnd {}

- (void)readSetBeginReturningElementType:(int *)elementType
                                     size:(int *)size
{
    [self readListBeginReturningElementType:elementType size:size];
}

- (void)readSetEnd {}

- (void)readListBeginReturningElementType:(int *)elementType
                                      size:(int *)size
{
    uint8_t readSizeAndType = [self readByte];
    uint32_t readSize = (readSizeAndType >> 4) & 0x0f;
    
    if (readSize == 15) {
        readSize = [self readVarint32];
    }
    
    uint8_t realType = [self getTType:(readSizeAndType & 0x0f)];

    if (elementType != NULL) {
        *elementType = realType;
    }
    if (size != NULL) {
        *size = readSize;
    }
}

- (void)readListEnd {}

- (int)readVarint32 {
    int result = 0;
    int shift = 0;
    
    while (true) {
        uint8_t b;
        [mTransport readAll:&b offset:0 length:1];
        result |= (int)(b & 0x7f) << shift;
        if ((b & 0x80) != 0x80) break;
        shift += 7;
    }
    
    return result;
}

// TODO: something fishy, when writing server gets it ok, but when reading, it fails
- (int64_t)readVarint64 {
    int64_t value = 0;
    int shift = 0;
    uint32_t rsize = 0;
    
    while (true) {
        uint8_t readByte;
        rsize += [mTransport readAll:&readByte offset:0 length:1];
        value |= (uint64_t)(readByte & 0x7f) << shift;
        shift += 7;
        
        if (!(readByte & 0x80)) {
            break;
        }
    }
    
    return value;
}

- (int)zigzagToInt:(int)n {
    return ((unsigned int)n >> 1) ^ -(n & 1);
}

- (int64_t)zigzagToI64:(uint64_t)n {
    return (n >> 1) ^ (uint64_t)(-(int64_t)(n & 1));
}

- (int)intToZigZag:(int)n {
    return (n << 1) ^ (n >> 31);
}

- (uint64_t)I64ToZigZag:(int64_t)l {
    return (l << 1) ^ (l >> 63);
}

- (int64_t)bytesToLong:(uint8_t *)bytes {
    return
    ((bytes[7] & 0xffLL) << 56) |
    ((bytes[6] & 0xffLL) << 48) |
    ((bytes[5] & 0xffLL) << 40) |
    ((bytes[4] & 0xffLL) << 32) |
    ((bytes[3] & 0xffLL) << 24) |
    ((bytes[2] & 0xffLL) << 16) |
    ((bytes[1] & 0xffLL) <<  8) |
    ((bytes[0] & 0xffLL));
}

- (void)fixedLongToBytes:(int64_t)n buf:(uint8_t *)buf offset:(int)offset {
    buf[offset+0] = (uint8_t)( n        & 0xff);
    buf[offset+1] = (uint8_t)((n >> 8 ) & 0xff);
    buf[offset+2] = (uint8_t)((n >> 16) & 0xff);
    buf[offset+3] = (uint8_t)((n >> 24) & 0xff);
    buf[offset+4] = (uint8_t)((n >> 32) & 0xff);
    buf[offset+5] = (uint8_t)((n >> 40) & 0xff);
    buf[offset+6] = (uint8_t)((n >> 48) & 0xff);
    buf[offset+7] = (uint8_t)((n >> 56) & 0xff);
}

- (void)writeMessageBeginWithName:(NSString *)name type:(int)messageType sequenceID:(int)sequenceID {
    [self writeByte:THRIFT_COMPACT_PROTOCOL_ID];
    [self writeByte:((THRIFT_COMPACT_VERSION & THRIFT_COMPACT_VERSION_MASK) | ((messageType << THIRFT_COMPACT_TYPE_SHIFT_AMOUNT) & THRIFT_COMPACT_TYPE_MASK))];
    [self writeVarint32:sequenceID];
    [self writeString:name];
}

- (void)writeByte:(uint8_t)value {
    [mTransport write:&value offset:0 length:1];
}

- (void)writeMessageEnd {}

- (void)writeStructBeginWithName:(NSString *)name
{
    [_lastField addObject:@(_lastFieldId)];
    _lastFieldId = 0;
}

- (void)writeStructEnd
{
    _lastFieldId = [((NSNumber *)[_lastField lastObject]) integerValue];
    [_lastField removeLastObject];
}

- (void)writeFieldBeginWithName:(NSString *)name
                           type:(int32_t)fieldType
                        fieldID:(int32_t)fieldID
{
    if ([self isBoolType:fieldType]) {
        // we want to possibly include the value, so we'll wait.
        _tempBoolField = @{@"name":name, @"fieldType":@(fieldType), @"fieldID":@(fieldID)};
    } else {
        [self writeFieldBeginInternalWithName:name type:fieldType fieldID:fieldID typeOverride:-1];
    }
}

- (void)writeFieldBeginInternalWithName:(NSString *)name type:(int)fieldType fieldID:(int)fieldID typeOverride:(int8_t)typeOverride
{
    // See if there is a type override
    uint8_t typeToWrite = (typeOverride == -1) ? [self getCompactType:fieldType] : typeOverride;
    
    if (fieldID > _lastFieldId && (fieldID - _lastFieldId) <= 15) {
        [self writeByte:((fieldID - _lastFieldId) << 4 | typeToWrite)];
    } else {
        [self writeByte:typeToWrite];
        [self writeI16:fieldID];
    }
    
    _lastFieldId = fieldID;
}

- (void)writeI32:(int32_t)value
{
    [self writeVarint32:[self intToZigZag:value]];
}

- (void)writeI16:(short)value
{
    [self writeVarint32:[self intToZigZag:value]];
}

- (void)writeI64:(int64_t)value
{
    [self writeVarint64:[self I64ToZigZag:value]];
}

- (void)writeVarint32:(uint32_t)value
{
    uint8_t bufferI32[5];
    uint32_t wsize = 0;

    while (YES) {
        if ((value & ~0x7F) == 0) {
            bufferI32[wsize++] = (uint8_t)value;
            break;
        } else {
            bufferI32[wsize++] = (uint8_t)((value & 0x7F) | 0x80);
            value >>= 7;
        }
    }

    [mTransport write:bufferI32 offset:0 length:wsize];
}

- (void)writeVarint64:(uint64_t)value
{
    uint8_t bufferI64[10];
    uint32_t wsize = 0;
    
    while (YES) {
        if ((value & ~0x7FL) == 0) {
            bufferI64[wsize++] = (uint8_t)value;
            break;
        } else {
            bufferI64[wsize++] = (uint8_t)((value & 0x7F) | 0x80);
            value >>= 7;
        }
    }
    
    [mTransport write:bufferI64 offset:0 length:wsize];
}

- (void)writeDouble:(double)value
{
    [mTransport write:(const uint8_t *)&value offset:0 length:sizeof(value)];
}

- (void)writeString:(NSString *)value
{
    if (value != nil) {
        const char * utf8Bytes = [value UTF8String];
        size_t length = strlen(utf8Bytes);
        [self writeBinary:[NSData dataWithBytes:utf8Bytes length:length]];
    } else {
        // instead of crashing when we get null, let's write out a zero
        // length string
        [self writeI32:0];
    }
}

- (void)writeBinary:(NSData *)data
{
    [self writeVarint32:(int32_t)[data length]];
    [mTransport write:[data bytes] offset:0 length:(int32_t)[data length]];
}

- (void)writeFieldStop
{
    [self writeByte:TType_STOP];
}

- (void)writeFieldEnd {}

- (void)writeMapBeginWithKeyType:(int)keyType
                       valueType:(int)valueType
                            size:(int)size
{
    if (size == 0) {
        [self writeByte:0];
    } else {
        [self writeVarint32:size];
        [self writeByte:([self getCompactType:keyType] << 4 | [self getCompactType:valueType])];
    }
}

- (void)writeMapEnd {}

- (void)writeSetBeginWithElementType:(int)elementType
                                size:(int)size
{
    [self writeCollectionBegin:elementType size:size];
}

- (void)writeSetEnd {}

- (void)writeListBeginWithElementType:(int)elementType
                                 size:(int)size
{
    [self writeCollectionBegin:elementType size:size];
}

- (void)writeListEnd {}

- (void)writeCollectionBegin:(uint8_t)elemType size:(int)size
{
    if (size <= 14) {
        [self writeByte:(size << 4 | [self getCompactType:elemType])];
    } else {
        [self writeByte:(0xf0 | [self getCompactType:elemType])];
        [self writeVarint32:size];
    }
}

- (void)writeBool:(BOOL)value
{
    if (_tempBoolField != nil) {
        NSString *name = _tempBoolField[@"name"];
        int32_t fieldType = (int32_t)[_tempBoolField[@"fieldType"] integerValue];
        int32_t fieldID = (int32_t)[_tempBoolField[@"fieldID"] integerValue];
        
        [self writeFieldBeginInternalWithName:name type:fieldType fieldID:fieldID typeOverride:value ? TCompactType_BOOLEAN_TRUE : TCompactType_BOOLEAN_FALSE];
        
        _tempBoolField = nil;
    } else {
        [self writeByte:(value ? 1 : 0)];
    }
}

- (BOOL)isBoolType:(uint8_t)b {
    int lowerNibble = b & 0x0f;
    return (lowerNibble == TCompactType_BOOLEAN_TRUE || lowerNibble == TCompactType_BOOLEAN_FALSE);
}

- (uint8_t)getTType:(uint8_t)type {
    switch ((uint8_t)(type & 0x0f)) {
        case TType_STOP:
            return TType_STOP;
        case TCompactType_BOOLEAN_FALSE:
        case TCompactType_BOOLEAN_TRUE:
            return TType_BOOL;
        case TCompactType_BYTE:
            return TType_BYTE;
        case TCompactType_I16:
            return TType_I16;
        case TCompactType_I32:
            return TType_I32;
        case TCompactType_I64:
            return TType_I64;
        case TCompactType_DOUBLE:
            return TType_DOUBLE;
        case TCompactType_BINARY:
            return TType_STRING;
        case TCompactType_LIST:
            return TType_LIST;
        case TCompactType_SET:
            return TType_SET;
        case TCompactType_MAP:
            return TType_MAP;
        case TCompactType_STRUCT:
            return TType_STRUCT;
        default:
            @throw [TProtocolException exceptionWithName: @"TProtocolException"
                                                  reason: @"Unknown type"];
    }
}

- (uint8_t)getCompactType:(uint8_t)ttype {
    switch(ttype) {
        case TType_STOP:
            return TType_STOP;
        case TType_BOOL:
            return TCompactType_BOOLEAN_TRUE;
        case TType_BYTE:
            return TCompactType_BYTE;
        case TType_I16:
            return TCompactType_I16;
        case TType_I32:
            return TCompactType_I32;
        case TType_I64:
            return TCompactType_I64;
        case TType_DOUBLE:
            return TCompactType_DOUBLE;
        case TType_STRING:
            return TCompactType_BINARY;
        case TType_LIST:
            return TCompactType_LIST;
        case TType_SET:
            return TCompactType_SET;
        case TType_MAP:
            return TCompactType_MAP;
        case TType_STRUCT:
            return TCompactType_STRUCT;
        default:
            @throw [TProtocolException exceptionWithName: @"TProtocolException"
                                                  reason: @"Unknown compact type"];
    }
    
    return 0;
}

@end
