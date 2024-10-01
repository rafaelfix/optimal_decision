#include <Foundation/Foundation.h>

@interface nativelib : NSObject

- (id) runFunction:(NSString *) name args:(NSArray *)args;

- (NSString *) getString;
- (NSString *) convint:(NSNumber *) num;

- (NSString *) setDataFile:(NSString *)fileName;
- (NSString *) checkFeasibleOperator:(NSString *)operator;
- (NSString *) newQuestion:(NSString *) operator;
- (void) clearQuestion;
- (void) addKey:(NSString *) key;
- (NSString *) determineAnswer;
- (NSString *) storeAnswer;
- (void) saveAnswerToFile;
- (NSString *) correctString:(NSString *) op;
- (NSString *) getQuestion;
- (NSNumber *) getX;
- (NSNumber *) getY;
- (NSNumber *) getZ;
- (NSNumber *) getAnswer;
- (NSNumber *) nHistory;
- (NSNumber *) nHistoryRows;
- (NSString *) getStatus;
- (NSNumber *) getLevel: (NSString *)op;
- (NSNumber *) statusTime: (NSString *)op;
- (NSString *) getDataTimes;
- (NSString *) getDataTimesStart: (NSNumber *) startQuestion;
- (NSString *) getDataInputs;
- (NSString *) getDataInputsStart: (NSNumber *)startQuestion;
- (NSArray *) getSolutionTimes: (NSNumber *) nLast;
- (void) gamingTimeStart;
- (void) gamingTimeEnd;
- (NSNumber *) gamingTimeAvail;
- (NSNumber *) gamingTimeCur;
- (NSString *) setFiles: (NSString *) nPath :(NSString *) nUserName;
- (NSString *) readGamingTimeFile;

@end
