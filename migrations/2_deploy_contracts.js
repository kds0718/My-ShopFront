var Shopfront = artifacts.require("./Shopfront.sol");
//var MetaCoin = artifacts.require("./Despacento.sol");

module.exports = function(deployer) {
  deployer.deploy(Shopfront);
  //deployer.link(ConvertLib, MetaCoin);
  //deployer.deploy(MetaCoin);
};
