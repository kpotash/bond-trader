
import Message
from dateutil import parser

class Header(Message.Message):
    def msgType(self, value = None):
        if None == value:
            return self.__buf[0:2].strip()
        else:
            self.__buf = self.__buf[:0] + str(value).ljust(2, " ")[:2] + self.__buf[2:]

    def brokerId(self, value = None):
        if None == value:
            return self.__buf[2:7].strip()
        else:
            self.__buf = self.__buf[:2] + str(value).ljust(5, " ")[:5] + self.__buf[7:]

    def assetClass(self, value = None):
        if None == value:
            val = self.__buf[7:9].strip()
            return int(val) if val else 0
        else:
            self.__buf = self.__buf[:7] + str(value).rjust(2, " ")[:2] + self.__buf[9:]

    def msgSeqNo(self, value = None):
        if None == value:
            val = self.__buf[9:14].strip()
            return int(val) if val else 0
        else:
            self.__buf = self.__buf[:9] + str(value).rjust(5, " ")[:5] + self.__buf[14:]

    def sendTime(self, value = None):
        if None == value:
            return parser.parse(self.__buf[14:40])
        else:
            self.__buf = self.__buf[:14] + value.isoformat().ljust(26, "0")[:26] + self.__buf[40:]

    def bodyLength(self, value = None):
        if None == value:
            val = self.__buf[40:45].strip()
            return int(val) if val else 0
        else:
            self.__buf = self.__buf[:40] + str(value).rjust(5, " ")[:5] + self.__buf[45:]

    def __init__(self):
        self.__buf = " " * 45

    def __repr__(self):
        return (super(Header, self).__repr__()
        + ", buffer length: {0}".format(len(self.__buf))
    
        + "\nmsgType: [" + str(self.msgType()) + "]"
        + "\nbrokerId: [" + str(self.brokerId()) + "]"
        + "\nassetClass: [" + str(self.assetClass()) + "]"
        + "\nmsgSeqNo: [" + str(self.msgSeqNo()) + "]"
        + "\nsendTime: [" + str(self.sendTime()) + "]"
        + "\nbodyLength: [" + str(self.bodyLength()) + "]")
