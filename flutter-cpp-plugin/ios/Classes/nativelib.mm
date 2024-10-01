#include <iostream>
#include <string>
#include "optQuestions.h"

@interface nativelib : NSObject

- (NSArray *) vector2array: (std::vector<double>) vec;

@end

@implementation nativelib : NSObject

optQ oq(1, 1, 1, 1, 1, 1);

- (id) runFunction:(NSString *) name args:(NSArray *)args {
    
    for (int i = 0; i < args.count; i++) {
        name = [name stringByAppendingString:@":"];
    }
    
    SEL method = NSSelectorFromString(name);
    NSMethodSignature *signature = [self methodSignatureForSelector: method];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature: signature];
    
    for (int i = 0; i < args.count; i++) {
        id arg = args[i];
        [inv setArgument:&arg atIndex:i + 2];
    }
    
    [inv setTarget: self];
    [inv setSelector:method];
    [inv invoke];

    
    if ([signature methodReturnLength] > 0) {
        __unsafe_unretained id retval;
        [inv getReturnValue: &retval];
        id val = retval;
        return val;
    }
    
    return nil;
}

- (NSString *) getstring {
    return @"hello from cpp";
}

- (NSString *) convint:(NSNumber *) num {
    return [NSString stringWithFormat:@"%d", num.intValue];
}

- (NSArray *) vector2array: (std::vector<double>) vec {
    NSMutableArray *res = [[NSMutableArray alloc] init];

    for (std::size_t i = 0; i < vec.size(); i++) {
        [res addObject:[NSNumber numberWithDouble: vec.at(i)]];
    }
    
    return (NSArray *)[res copy];
}

- (NSString *) setDataFile:(NSString *)fileName {
    std::string cfileName = std::string([fileName UTF8String]);
    try
    {
        oq.setDataFile(cfileName);
    }
    catch (ExcQuestions &e)
    {
        return [NSString stringWithUTF8String:e.what().c_str()];
        throw;
    }
    catch (std::exception &e)
    {
        return [NSString stringWithUTF8String:e.what()];
    }
    catch (...)
    {
        return @"There was an error!\n";
    }
    return @"";
}

- (NSString *) checkFeasibleOperator:(NSString *)op {
    try
    {
        std::string operatorStr = std::string([op UTF8String]); 
        char operatorChar = operatorStr.at(0);
        char necessaryOperator = oq.checkFeasibleOperator(operatorChar);
        std::string tmp(1, necessaryOperator);
        return [NSString stringWithUTF8String:tmp.c_str()];
    }
    catch (ExcQuestions &e)
    {
        return [NSString stringWithUTF8String:e.what().c_str()];
        throw;
    }
    catch (std::exception &e)
    {
        return [NSString stringWithUTF8String:e.what()];
    }
    catch (...)
    {
        return @"There was an error!\n";
    }
    return @"";
}

- (NSString *) newQuestion:(NSString *) op {
    try
    {
        std::string operatorStr = std::string([op UTF8String]); 
        char operatorChar = operatorStr.at(0);
        oq.newQuestion(operatorChar);
    }
    catch (ExcQuestions &e)
    {
        return [NSString stringWithUTF8String:e.what().c_str()];
        throw;
    }
    catch (std::exception &e)
    {
        return [NSString stringWithUTF8String:e.what()];
    }
    catch (...)
    {
        return @"There was an error!\n";
    }
    return @"";
}

- (void) clearQuestion {
    oq.clearQuestion();
}

- (void) addKey:(NSString *) keyStr {
    std::string keys = std::string([keyStr UTF8String]);
    char key = keys.at(0);
    oq.addKey(key);
}

- (NSString *) determineAnswer {
    try
    {
        oq.determineAnswer();
    }
    catch (ExcQuestions &e)
    {
        return [NSString stringWithUTF8String:e.what().c_str()];
        throw;
    }
    catch (std::exception &e)
    {
        return [NSString stringWithUTF8String:e.what()];
    }
    catch (...)
    {
        return @"There was an error!\n";
    }
    return @"";
}

- (NSString *) storeAnswer {
    try
    {
        oq.storeAnswer();
    }
    catch (ExcQuestions &e)
    {
        return [NSString stringWithUTF8String:e.what().c_str()];
        throw;
    }
    catch (std::exception &e)
    {
        return [NSString stringWithUTF8String:e.what()];
    }
    catch (...)
    {
        return @"There was an error!\n";
    }
    return @"";
}

- (void) saveAnswerToFile {
    oq.saveAnswerToFile();
}

- (NSString *) correctString:(NSString *) op {
    std::string operatorStr = std::string([op UTF8String]);
    char operatorChar = operatorStr.at(0);
    std::string str = oq.correctString(operatorChar);
    return [NSString stringWithUTF8String:str.c_str()];
}

- (NSString *) getQuestion {
    std::string question = oq.getQuestion();
    return [NSString stringWithUTF8String:question.c_str()];
}

- (NSNumber *) getX {
    int xValue = oq.getX();
    return [NSNumber numberWithInteger: xValue];
}

- (NSNumber *) getY {
    int yValue = oq.getY();
    return [NSNumber numberWithInteger: yValue];
}

- (NSNumber *) getZ {
    int zValue = oq.getZ();
    return [NSNumber numberWithInteger: zValue];
}

- (NSNumber *) getAnswer {
    int answer = oq.getAnswer();
    return [NSNumber numberWithInteger: answer];
}

- (NSNumber *) nHistory {
    int nHistory = oq.nHistory();
    return [NSNumber numberWithInteger: nHistory];
}

- (NSNumber *) nHistoryRows {
    int nHistoryRows = oq.nHistory();
    return [NSNumber numberWithInteger: nHistoryRows];
}

- (NSString *) getStatus {
    std::string status = oq.status();
    return [NSString stringWithUTF8String: status.c_str()];
}

- (NSNumber *) getLevel: (NSString *)op {
    const char *op_cs = [op UTF8String];
    unsigned int level = oq.level(op_cs[0]);
    return [NSNumber numberWithInteger: (int)level];
}

- (NSNumber *) statusTime: (NSString *)op {
    const char *op_cs = [op UTF8String];
    double time = oq.statusTime(op_cs[0]);
    NSNumber *ret = [NSNumber numberWithDouble: time];
    return ret;
}

- (NSString *) getDataTimes {
    std::string status = oq.getDataTimes();
    return [NSString stringWithUTF8String: status.c_str()];
}

- (NSString *) getDataTimesStart: (NSNumber *) startQuestion {
    std::string status = oq.getDataTimes(startQuestion.intValue);
    return [NSString stringWithUTF8String: status.c_str()];
}

- (NSString *) getDataInputs {
    std::string status = oq.getDataInputs();
    return [NSString stringWithUTF8String: status.c_str()];
}

- (NSString *) getDataInputsStart: (NSNumber *)startQuestion {
    std::string status = oq.getDataInputs(startQuestion.intValue);
    return [NSString stringWithUTF8String: status.c_str()];
}

- (NSArray *) getSolutionTimes: (NSNumber *) nLast {
    std::vector<double> times = oq.getSolutionTimes(nLast.intValue);
    return [self vector2array: times];
}

- (NSString *) getGamingTimeFile: (NSString *)nFileName {
    std::string fileName = std::string([nFileName UTF8String]);
    try
    {
        oq.setGamingTimeFile(fileName);
    }
    catch (ExcQuestions &e)
    {
        return [NSString stringWithUTF8String:e.what().c_str()];
        throw;
    }
    catch (std::exception &e)
    {
        return [NSString stringWithUTF8String:e.what()];
    }
    catch (...)
    {
        return @"There was an error!\n";
    }
    return @"";
}

- (void) gamingTimeStart {
    oq.gamingTimeStart();
}

- (void) gamingTimeEnd {
    oq.gamingTimeEnd();
}

- (NSNumber *) gamingTimeAvail {
    return [NSNumber numberWithDouble: oq.gamingTime() - oq.spentGamingTime()];
}

- (NSNumber *) gamingTimeCur {
    return [NSNumber numberWithDouble: oq.spentGamingTimeCur()];
}

- (NSString *) setFiles: (NSString *) nPath :(NSString *) nUserName {
    std::string path = std::string([nPath UTF8String]);
    std::string userName = std::string([nUserName UTF8String]);
    std::string fileName = path + "/optCalcDigit" + userName + ".txt";
    std::string gtFileName = path + "/optGamingTime" + userName + ".txt";
    try
    {
        oq.setDataFile(fileName);
        oq.setGamingTimeFile(gtFileName);
    }
    catch (ExcQuestions &e)
    {
        return [NSString stringWithUTF8String:e.what().c_str()];
        throw;
    }
    catch (std::exception &e)
    {
        return [NSString stringWithUTF8String:e.what()];
    }
    catch (...)
    {
        return @"There was an error!\n";
    }
    return @"";
}

- (NSString *) readGamingTimeFile {
    return [NSString stringWithUTF8String: oq.readGamingTimeFile().c_str()];
}

@end
