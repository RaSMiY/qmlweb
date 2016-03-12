import QtQuick 2.0

Item { //QtObject not implemented yet
  id: testCase
  property string name: ""

  property int delay: 25        //delay before running test
  property int timeout: 1000      //delay before killing the test
  property int expectations: 0    //not implemented


  property bool __isTest: true    //identify test objects
  property var compareRender      //holds the image compare function
  property var done               //holds the done function
  property var jasmine            //jasmine variable from node
  property var testFunctions: []  //test functions in loaded element

  Timer {
    id: startupTimer
    interval: delay + (jasmine === undefined ? 1000 : 0)
    triggeredOnStart: false
    onTriggered: {
      //looks for a function named 'test' and executes it
      //the function can have an optional callback argument
      for (var prop in testCase) {
        if(prop !== "test") continue;
        var testFunc = testCase[prop];
        if(typeof testFunc !== 'function') continue;
        testFunc(testCase.done);
        if(testFunc.length === 0)
          testCase.done();
      }
    }
  }

  Timer {
    id: timeoutTimer
    interval: timeout + (jasmine === undefined ? 5000 : 0)
    onTriggered: {
      fail("Timed out after " + interval);
      testCase.done();
    }
  }

  //called explicitly from loade.qml or jasmine test
  function start(done) {
    console.log("Start");
    timeoutTimer.start();
    startupTimer.start();
    this.done = done;
  }

  //test functions
  function expect(value){
    if(jasmine !== undefined)
      return jasmine.expect(value);
    else return qtExpect(value);
  }
  function fail(message){
    if(jasmine !== undefined)
      return jasmine.fail(message);
    else return qtFail(message);
  }
  function pass(message){
    if(jasmine !== undefined)
      return jasmine.pass(message);
    else return qtPass(message);
  }

  //Qt implementation
  function qtExpect(value){
    return {
       toBe: function(expected){
         if(expected === value) qtPass("");
         else qtFail("expected " + value + " to be " + expected);
       }
     }
  }
  function qtPass(message){
    var file = script.split("/").pop().replace(".qml", "");
    console.log("PASS " + file + ": ");
  }

  function qtFail(message){
    var file = script.split("/").pop().replace(".qml", "");
    console.log("FAIL " + file + ": " + message);
  }
}
