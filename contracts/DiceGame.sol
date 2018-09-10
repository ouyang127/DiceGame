pragma solidity ^0.4.23;

import "./Ownable.sol";
import "./Safemath.sol";

contract DiceGame is Ownable{
	using SafeMath for uint;
	uint constant DEPOSIT = 12 * (10 ** 18) ;

	uint public prizePool;
	uint public fee; // reward owner

	uint public id = 1;
         
        //user's information
	struct diceInfo{
		address user;
		uint  first;
		uint second;
	}

	mapping(uint => diceInfo[]) public diceInfos;//for save the useres


	event WithDraw(address owner, uint fee); // to owner
	event Dice(address player,  uint first, uint second);// to player
	event Prize(address player, uint prize, uint fee);// to player


	constructor () public payable { // init prizePool 
		prizePool = msg.value;
	}

	function () public payable {}//for transaction

	function withdraw() public onlyOwner { //owner's fee
		owner.transfer(fee);
		fee = 0;
		emit WithDraw(msg.sender,  fee);
	}
        
	function dice(uint _id) public payable returns (bool){ 
		// value must be 12 or you can set another number
		require (msg.value == DEPOSIT);
		// _id == id ,else dice error, rollback 
                 require(_id == id);
                 //this,you will get your number
		(uint first, uint second) = randDice(random(diceInfos[id].length));
		emit Dice(msg.sender, first, second);

		diceInfo memory info = diceInfo ({
			user : msg.sender,
			first: first,
			second: second });
			
		diceInfos[id].push(info);
		 
		uint value = first.add(second).mul(10 ** 18);
		prizePool = prizePool.add(value);

		// make change
		if (value != DEPOSIT) {
			msg.sender.transfer(DEPOSIT.sub(value));
		}

		// winner
		if (first == 1 && second == 1) {	
			uint roundFee = prizePool.div(100);
			uint prize    = prizePool.div(100).mul(80);

			msg.sender.transfer(prize);
			emit Prize(msg.sender, prize, roundFee);

			prizePool = prizePool.div(100).mul(10); // 10% 
			fee = fee.add(roundFee);
			id++;
			return true;
		}

		return false;
	}
    //get length
    function getDiceCount(uint _id) public view returns(uint) {
    	return diceInfos[_id].length;
    }
        // rand number for player
	function randDice(uint randNumber) private pure returns (uint first, uint second) {
		uint[6] memory diceNumber = [uint(1), 2, 3, 4, 5, 6];

		first = diceNumber[randNumber % 6];
		randNumber <<= 8 * 2;
		second = diceNumber[randNumber % 6];

		return (first, second);
	}
        
        // this is rand number,using keccak256.
	function random(uint seed) private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.coinbase, now, block.number, seed)));
    }

}
