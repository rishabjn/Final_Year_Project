var Election = artifacts.require("./Main.sol");

module.exports = function(deployer) {
  deployer.deploy(Election);
};
