
import os,sys,inspect
sys.path.insert(0,"../src") 

import datetime

import Message
import Header

def main():
    msg = Message.Message()
    header = Header.Header()
    header.msgType("5")
    header.brokerId("IBEX")
    header.sendTime(datetime.datetime.now())
    header.msgSeqNo(1258888)
    print "Message is: ", msg
    print "Header is: ", header

if "__main__" == __name__:
    main()
