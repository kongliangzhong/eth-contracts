const LockBox = artifacts.require("LockBox");

module.exports = function(deployer) {
  deployer.deploy(LockBox);
};
