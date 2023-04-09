//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 < 0.9.0; 

contract Upload{

    //who have the access to the image or files,.
    struct Access{
        address user;
        bool access;
    }

    //for every address user can sotre as many image or file as he want . that is stored in mapping.
    mapping(address=>string[])value;

    //owner of a image or file gave access to whom is stored in accesslist
    mapping(address=>Access[])accesslist;

    mapping(address=>mapping(address=>bool))ownership;
    mapping(address=>mapping(address=>bool))previousData;

    function add(address _user,string memory url) external{
        value[_user].push(url);
    }
    
    function allow(address user) external{
        ownership[msg.sender][user]=true;
        if(previousData[msg.sender][user]){
            for(uint i=0;i<accesslist[msg.sender].length;i++){
                if(accesslist[msg.sender][i].user==user){
                      accesslist[msg.sender][i].access=true;
                }
            }
        }else{
             accesslist[msg.sender].push(Access(user,true));
            previousData[msg.sender][user]=true;
        }
       

    }

    function disallow (address _user) public{
        ownership[msg.sender][_user]=false;
        for(uint i=0;i<accesslist[msg.sender].length;i++){
            if(accesslist[msg.sender][i].user==_user){
                accesslist[msg.sender][i].access=false;
            }
        }
    }
    function display (address _user) external view returns (string [] memory){
        require(_user==msg.sender || ownership[_user][msg.sender],"You dont have access");
        return value[_user];
    }

    function shareAcess() public view returns (Access[] memory){
        return accesslist[msg.sender];
    }

}