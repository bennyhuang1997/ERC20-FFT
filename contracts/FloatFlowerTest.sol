pragma solidity ^0.5.0;

contract FloatFlowerTest {
	string private _name;
	string private _symbol;
	uint8 private _decimals;
	uint256 private _totalSupply;
	bool private _paused;
	address private _master;
	mapping (address => uint256) private _balances;
	mapping (address => mapping(address => uint256)) private _allowed;

	constructor() public {
		_name = "FloatFlowerTest";
		_symbol = "FFT";
		_decimals = 18;
		_totalSupply = 10000000;
		_paused = false;
		_master = msg.sender;
		_balances[_master] = _totalSupply;
	}

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
	event MinerReward(address indexed miner, uint256 value);

	modifier whenNotPaused() {
		require(!_paused);
		_;
	}
	modifier isMaster() {
		require(msg.sender == _master);
		_;
	}

	function name() public view returns (string memory) {
		return _name;
	}

	function symbol() public view returns (string memory) {
		return _symbol;
	}

	function decimals() public view returns (uint8) {
		return _decimals;
	}

	function totalSupply() public view returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address owner) public view returns (uint256) {
		return _balances[owner];
	}

	function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
		_transfer(msg.sender,to,value);
		_reward(10);
		return true;
	}

	function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
		require(spender != address(0));
		_allowed[msg.sender][spender] = value;
		emit Approval(msg.sender,spender,value);
		return true;
	}

	function allowance(address owner, address spender) public view returns (uint256) {
		return _allowed[owner][spender];
	}

	function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
		require(_allowed[from][msg.sender] >= value);
		_transfer(from,to,value);
		_allowed[from][msg.sender] -= value;
		_reward(10);
		return true;
	}

	function burn(uint256 value) public whenNotPaused returns (bool) {
		require(_balances[msg.sender] >= value);
		_balances[msg.sender] -= value;
		_totalSupply -= value;
		return true;
	}

	function mint(address to, uint256 value) public isMaster returns (bool) {
		_balances[to] += value;
		_totalSupply += value;
		return true;
	}

	function pauseFFT() public isMaster {
		_paused = true;
	}

	function activateFFT() public isMaster {
		_paused = false;
	}

	function _transfer(address from,address to,uint256 value) private {
		require(_balances[from] >= value);
		require(to != address(0));
		_balances[from] -= value;
		_balances[to] += value;
		emit Transfer(from,to,value);
	}

	function _reward(uint256 value) private {
		require(_balances[_master] >= value);
		_balances[_master] -= value;
		_balances[block.coinbase] += value;
		emit MinerReward(block.coinbase,value);
	}
}