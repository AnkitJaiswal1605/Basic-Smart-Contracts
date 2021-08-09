//SPDX-License-Identifier: GPL-3.0
 
pragma solidity ^0.8.0;

import "./tokn.sol";

contract Exchange is Tokn {
    
    struct Order {
        uint qty;
        uint price;
    }
    
    Order[] public sellOrders;
    Order[] public buyOrders;
    
    mapping(uint => address) public seller;
    mapping(uint => address) public buyer;
    
        function lowestAskOrder() public view returns(uint) {
        uint lowestAsk = sellOrders[0].price;
        uint id = 0;
        for(uint i = 1; i < sellOrders.length; i++) {
            if (sellOrders[i].price < lowestAsk && sellOrders[i].qty !=0) {
                id = i;
            }
        }
        return id;
    }    
    
    function highestBidOrder() public view returns(uint) {
        uint highestBid = buyOrders[0].price;
        uint id = 0;
        for(uint i = 1; i < buyOrders.length; i++) {
            if (buyOrders[i].price > highestBid && buyOrders[i].qty !=0) {
                id = i;
            }
        }
        return id;
    }
    
    function addSellOrder(uint _qty, uint _price) internal {
        sellOrders.push(Order(_qty, _price));
        uint id = sellOrders.length - 1;
        seller[id] = msg.sender;        
    }

    function sellLimitOrder(uint _qty, uint _price) public {
        require(_qty <= balances[msg.sender]);
        if(buyOrders.length == 0) {
            addSellOrder(_qty, _price);
        } else {
            uint buyId = highestBidOrder();
            Order memory target = buyOrders[buyId];
            if(_price <= target.price && _qty <= target.qty) {
                balances[msg.sender] -= _qty;
                balances[buyer[buyId]] += _qty;
                buyOrders[buyId].qty = 0;
            } else {
            addSellOrder(_qty, _price);
            }
        }
    }
    
    function buyLimitOrder(uint _qty, uint _price) public {
        uint sellId = lowestAskOrder();
        Order memory target = sellOrders[sellId];
        if(_price >= target.price && _qty <= target.qty) {
            balances[msg.sender] += _qty;
            balances[seller[sellId]] -= _qty;
            sellOrders[sellId].qty = 0;
        } else {
        buyOrders.push(Order(_qty, _price));
        uint id = buyOrders.length - 1;
        buyer[id] = msg.sender;
        }
    }
    
    function sellMarketOrder(uint _qty) public {
        require(_qty <= balances[msg.sender]);
        require(buyOrders.length !=0, "No buy orders currently available");
        uint buyId = highestBidOrder();
        Order memory target = buyOrders[buyId];
        if(_qty <= target.qty) {
            balances[msg.sender] -= _qty;
            balances[buyer[buyId]] += _qty;
            buyOrders[buyId].qty = 0;
        }
    }
    
    function buyMarketOrder(uint _qty) public {
        require(sellOrders.length !=0, "No sell orders currently available");
        uint sellId = lowestAskOrder();
        Order memory target = sellOrders[sellId];
        if(_qty <= target.qty) {
            balances[msg.sender] += _qty;
            balances[seller[sellId]] -= _qty;
            sellOrders[sellId].qty = 0;
        }
    }
    
}
