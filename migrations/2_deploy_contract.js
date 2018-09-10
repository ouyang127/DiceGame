var diceGame = artifacts.require("./DiceGame.sol");

module.exports = function(deployer) {
  deployer.deploy(diceGame);
};