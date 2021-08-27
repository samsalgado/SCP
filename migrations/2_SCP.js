const SupplyChainProtocol = artifacts.require("SupplyChainProtocol");

module.exports = function (deployer) {
  deployer.deploy(SupplyChainProtocol);
};

