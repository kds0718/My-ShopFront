pragma solidity ^0.4.8;
/*
//DespaCento Coin Creation 

pragma solidity ^0.4.16;

contract despaCento {
    
    mapping (address => uint256) public balanceOf; 
    mapping (address => mapping(address => uint256)) allowed; 
    
    string public symbol = "DSC";
    string public name ="DespaCento";
    uint8 public decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function despaCento()
    {
        balanceOf[msg.sender] = 1000000; 
        /*To Do - Later test out ability to buy coin with Ether
        keeping it simple for now. 
    }
      
      function transfer(address _to, uint256 _value)
        public
        returns (bool success)
      {
          require(balanceOf[msg.sender] >= _value
          && balanceOf[_to] + _value >= balanceOf[_to]);
          
          balanceOf[msg.sender] -= _value;
          balanceOf[_to] += _value; 
          
          Transfer(msg.sender, _to, _value);
          
          return true; 
      }
    
    function transferFrom(address _from, address _to, uint256 _value)
        returns (bool success)
        {
            //Check and see if another address can do the transfer.
            require(_value <= allowed[_from][msg.sender]);
            allowed[_from][msg.sender] -= _value; 
            _transfer(_from, _to, _value);
            return true;
        }
    
    function _transfer (address _from, address _to, uint _value)
        internal 
        {
            require(_to != 0x0
            && balanceOf[_from] >= _value
            && balanceOf[_to] + _value > balanceOf[_to]);
            balanceOf[_from] -= _value; 
            balanceOf[_to] += _value;
            //Logging event
            Transfer(_from, _to, _value);
        }
    
    function approve(address _spender, uint256 _value)
        returns (bool success) 
        {
            allowed[msg.sender][_spender] = _value; 
            return true;
        }
}
*/