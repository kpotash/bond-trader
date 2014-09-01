import dateutil
class Message(object):

  
    def msgType(self):
        return ""
    def msgType(self, value):
        pass

  
    def sendTime(self):
        return dateutil.parser.parse("1970-01-01T00:00:00.000000")
    def sendTime(self, value):
        pass

  
    def bodyLength(self):
        return 0
    def bodyLength(self, value):
        pass

  
    def brokerId(self):
        return ""
    def brokerId(self, value):
        pass

  
    def assetClass(self):
        return 0
    def assetClass(self, value):
        pass

  
    def msgSeqNo(self):
        return 0
    def msgSeqNo(self, value):
        pass

  
  
    def initiatorId(self):
        return ""
    def initiatorId(self, value):
        pass

  
    def isin(self):
        return ""
    def isin(self, value):
        pass

  
    def description(self):
        return ""
    def description(self, value):
        pass

  
    def price(self):
        return 0
    def price(self, value):
        pass

  
    def direction(self):
        return ""
    def direction(self, value):
        pass

  
    def orderId(self):
        return ""
    def orderId(self, value):
        pass


    def __repr__(self):
        return "class: {0}".format(self.__class__.__name__)
