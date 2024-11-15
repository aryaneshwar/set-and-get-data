const Crowdfunding = artifacts.require("Crowdfunding");

module.exports = async function (deployer) {
    await deployer.deploy(Crowdfunding);
};