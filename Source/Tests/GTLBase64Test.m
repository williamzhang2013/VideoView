/* Copyright (c) 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <XCTest/XCTest.h>

#import "GTLBase64.h"

@interface GTLBase64Test : XCTestCase
@end

@implementation GTLBase64Test

- (void)testBase64Conversion {
  NSMutableString *testStr = [NSMutableString string];
  for (unichar idx = 1; idx < 500; idx += 15) {
    [testStr appendFormat:@"%C", idx];
  }
  NSString *testEncodedStd = @"ARAfLj1MW2p5wojCl8KmwrXDhMOTw6LDscSAxI/EnsStxLzF"
                             @"i8WaxanFuMaHxpbGpca0x4PHksehx7A=";
  NSString *testEncodedWeb = @"ARAfLj1MW2p5wojCl8KmwrXDhMOTw6LDscSAxI_EnsStxLzF"
                             @"i8WaxanFuMaHxpbGpca0x4PHksehx7A=";

  // Encoding
  NSData *data = nil;
  NSString *result = GTLEncodeBase64(data);
  XCTAssertNil(result, @"nil base64 data");

  data = [NSData data];
  result = GTLEncodeBase64(data);
  NSString *expected = @"";
  XCTAssertEqualObjects(result, expected, @"empty base64 data");

  NSString *str = testStr;
  data = [testStr dataUsingEncoding:NSUTF8StringEncoding];

  result = GTLEncodeBase64(data);
  expected = testEncodedStd;
  XCTAssertEqualObjects(result, expected, @"test data");

  result = GTLEncodeWebSafeBase64(data);
  expected = testEncodedWeb;
  XCTAssertEqualObjects(result, expected, @"test data ws");

  // Decoding
  str = nil;
  data = GTLDecodeBase64(str);
  XCTAssertNil(data, @"nil string");

  str = @"kjh"; // not valid base64
  data = GTLDecodeBase64(str);
  XCTAssertNil(data, @"invalid string");

  str = @"";
  data = GTLDecodeBase64(str);
  XCTAssertEqualObjects(data, [NSData data], @"empty string");

  str = testEncodedStd;
  data = GTLDecodeBase64(str);
  NSData *expectedData = [testStr dataUsingEncoding:NSUTF8StringEncoding];
  XCTAssertEqualObjects(data, expectedData, @"test string");

  str = testEncodedWeb;
  data = GTLDecodeWebSafeBase64(str);
  expectedData = [testStr dataUsingEncoding:NSUTF8StringEncoding];
  XCTAssertEqualObjects(data, expectedData, @"test string ws");
}
@end
