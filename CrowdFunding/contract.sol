//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 < 0.9.0; 

contract CrowdFuncding{
    mapping(address=>uint)public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool)voters;
    }
    mapping(uint=>Request) public requests;
    uint public numRequests;
    constructor(uint _target,uint _deadline){
        target=_target;
        deadline=block.timestamp+_deadline;
        minimumContribution=100 wei;
        manager=msg.sender;
    }

    function sendEth() public payable{
        require(block.timestamp<deadline,"Deadline has passed");
        require(msg.value>=minimumContribution,"Minimum Contribution is not met");
        require(contributors[msg.sender]==0,"Cannot contribute more than once");
        noOfContributors++;
        contributors[msg.sender]=msg.value;
        raisedAmount+=msg.value;
        
    }

    function getContractBalance() public view returns (uint){
        return address(this).balance;
    }
    function refund() public{
        require(block.timestamp>deadline && raisedAmount<target,"You are not eligible for refund");
        require(contributors[msg.sender]>0,"You did not contribute to get refund");
        address payable user =payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
        noOfContributors--;
    }

    modifier onlyManager(){
        require(msg.sender==manager,"Only managercal call this function");
        _;
    }

    function createRequests(string memory _description,address payable _recipient,uint value) public onlyManager{
        Request storage newRequest=requests[numRequests];
        numRequests++;
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=value;
        newRequest.completed=false;
        newRequest.noOfVoters=0;
    }
    function voteRequest(uint _requestno) public{
        require(contributors[msg.sender]>0,"You must be a contributor");
        Request storage thisRequest=requests[_requestno];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;


    }
    function makePayment(uint _requestno)public onlyManager{
        require(raisedAmount>=target);
        Request storage thisRequest=requests[_requestno];
        require(thisRequest.completed==false,"This request has been completed");
        require(thisRequest.noOfVoters>noOfContributors/2,"less than 50% people denied support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
        raisedAmount-=thisRequest.value;

    }

}