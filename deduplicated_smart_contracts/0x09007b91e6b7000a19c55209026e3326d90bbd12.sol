#                          __....-------....__
#                    ..--'"                   "`-..
#                 .'"                              `.
#               :'                                   `,
#             .'                                       ".
#            :                                           :
#           :                                             b
#          d                                              `b
#          :                                               :
#          :                                               b
#         :                                                q
#         :                                                `:
#        :                                                  :
#       ,'                                                  :
#      :    _____                  _____                   p'
#      \,.-'     `-.            .-'     `-.                :
#      .'           `.        .'           `.              :
#     /               \      /               \            p'
#    :      @          ;    :      @          ;           :
#    |                 |    |                 |           :
#    :                 ;    :                 ;          ,:
#     \               /      \               /           p
#     /`.           .'        `.           .'           :
#    q_  `-._____.-.            `-._____.-'             :
#     /"-__     .""           "-.__                    :'
#    (_    ""-.'                   """---8008135       :
#      "._.-""                                        ,:
#     ,""                                             P
#   ."                                                :
#  "      _."      ."        ."        _...           :
# P     ."        "        .'        ,"####)          :
#:     ."       ."        /        ,'######'          :
#:     :       (        ,"        ,########:         ,:
# q    `.      '.       ,        :######,-'          :
# `:    b       q       :        '--''""             :
#  :     :      :       :        :                   :
#  :     :      `:      `.       ".                 :'
#  q_    :       :       :         )                :
#    ""'b`._   ,.`.____,' `._   _.'                 ,
#       |.__"""              """     _______.......',
#     ,'    """""""-----.------"""""""               :
#     :                 :                            :
#     :                 :                            :
#     :.__              :           ________.......,'
#         """"""""------'------""""""
# @version ^0.2.7

## On margin! Zoidey wanna buy on margin! ##

# Auction params
# Beneficiary receives money from the hihghest bidder

beneficiary: public(address)
auctionStart: public(uint256)
auctionEnd: public(uint256)

# Current state of auctionEnd
highestBidder: public(address)
highestBid: public(uint256)

# Set to true at the end, disallows any chaange
ended: public(bool)

pendingReturns: public(HashMap[address, uint256])

@external
def __init__(_beneficiary: address, _auction_start: uint256, _bidding_time: uint256):

  self.beneficiary = _beneficiary
  self.auctionStart = _auction_start
  self.auctionEnd = self.auctionStart + _bidding_time

@external
@payable
def bid():
  assert block.timestamp >= self.auctionStart
  assert block.timestamp >= self.auctionEnd
  assert msg.value > self.highestBid
  self.pendingReturns[self.highestBidder] += self.highestBid
  self.highestBidder = msg.sender
  self.highestBid = msg.value

@external
def endAuction():
  assert block.timestamp >= self.auctionEnd
  assert not self.ended

  self.ended = True

  send(self.beneficiary, self.highestBid)