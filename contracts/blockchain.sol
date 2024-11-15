// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract Crowdfunding {
    struct Campaign {
        uint256 id;
        string name;
        address owner;
        uint256 targetAmount;
        uint256 totalAmount;
        bool isActive;
    }

    uint256 public totalCampaigns;
    mapping(uint256 => Campaign) public campaigns;
    mapping(address => mapping(uint256 => uint256)) public contributions;

    event CampaignCreated(uint256 id, string name, address owner, uint256 targetAmount);
    event Contributed(address contributor, uint256 campaignId, uint256 amount);

    modifier onlyActive(uint256 campaignId) {
        require(campaigns[campaignId].isActive, "Campaign is not active");
        _;
    }

    function createCampaign(string memory name, uint256 targetAmount) public {
        require(targetAmount > 0, "Target amount must be greater than 0");
        
        totalCampaigns++;
        campaigns[totalCampaigns] = Campaign(totalCampaigns, name, msg.sender, targetAmount, 0, true);
        
        emit CampaignCreated(totalCampaigns, name, msg.sender, targetAmount);
    }

    function contribute(uint256 campaignId) public payable onlyActive(campaignId) {
        require(msg.value > 0, "Contribution must be greater than 0");

        contributions[msg.sender][campaignId] += msg.value;
        campaigns[campaignId].totalAmount += msg.value;


        if (campaigns[campaignId].totalAmount >= campaigns[campaignId].targetAmount) {
            campaigns[campaignId].isActive = false;
        }

        emit Contributed(msg.sender, campaignId, msg.value);
    }

    function getCampaign(uint256 campaignId) public view returns (uint256, string memory, address, uint256, uint256, bool) {
        Campaign memory campaign = campaigns[campaignId];
        return (campaign.id, campaign.name, campaign.owner, campaign.targetAmount, campaign.totalAmount, campaign.isActive);
    }

    function withdraw(uint256 campaignId) public {
        require(msg.sender == campaigns[campaignId].owner, "Only campaign owner can withdraw");
        require(campaigns[campaignId].totalAmount >= campaigns[campaignId].targetAmount, "Target not met");
        require(campaigns[campaignId].isActive, "Campaign must be active to withdraw");

        uint256 amount = campaigns[campaignId].totalAmount;
        campaigns[campaignId].totalAmount = 0;
        campaigns[campaignId].isActive = false; // Optionally set inactive after withdrawal
        payable(msg.sender).transfer(amount);
    }

    function closeCampaign(uint256 campaignId) public {
        require(msg.sender == campaigns[campaignId].owner, "Only campaign owner can close");
        campaigns[campaignId].isActive = false;
    }
}