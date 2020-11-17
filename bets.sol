 pragma solidity >=0.4.24 <0.7.0;
 
 contract Bet {
     
     address private owner;
     mapping ( address => uint256) bets;
     address payable[] public players;
     uint8 public n_players;
     uint8 currentPlayers = 0;
     
     modifier isOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }
    
    constructor(uint8 _n_players) public {
        if (_n_players == 0) { revert("Someone needs to play. The number of players can't be zero"); }
        owner = msg.sender;
        n_players = _n_players;
    }
    
    function contains(address _wallet) private view returns (bool){
        return bets[_wallet] != 0;
    }
    
    function bet() payable public {
        if (contains(msg.sender)) { revert("You are already in the game"); }
        if (currentPlayers == n_players) { revert("Sorry, the game is full"); }
        bets[msg.sender] = msg.value;
        players.push(msg.sender);
        currentPlayers++;
    }
    
    function getMyBet() public view returns (uint256) {
        return bets[msg.sender];
    }
    
    function getWinner() public view isOwner returns (address payable, uint256) {
        uint256 maxBet = 0;
        uint256 second = 0;
        address payable bigLoser;
        address payable winner;
        for(uint8 i=0; i < currentPlayers; i++){
            if (bets[players[i]] > maxBet) {
                second = maxBet;
                maxBet = bets[players[i]];
                winner = bigLoser;
                bigLoser = players[i];
            } else if (bets[players[i]] > second) {
                second = bets[players[i]];
                winner = players[i];
            }
        }
        return (winner, second);
    }
    
    function closeGame() public isOwner {
        (address payable winner, uint256 value) = getWinner();
        winner.transfer(address(this).balance);
    }
     
 }
