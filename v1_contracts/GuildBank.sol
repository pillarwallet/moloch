pragma solidity 0.5.3;

import "./oz/Ownable.sol";
import "./oz/IERC20.sol";
import "./oz/SafeMath.sol";
import "./ERC20Wrapper.sol";

contract GuildBank is Ownable {
    using SafeMath for uint256;

    IERC20 public approvedToken; // approved token contract reference

    event Withdrawal(address indexed receiver, uint256 amount);

    constructor(address approvedTokenAddress) public {
        approvedToken = IERC20(approvedTokenAddress);
    }

    function withdraw(address receiver, uint256 shares, uint256 totalShares) public onlyOwner returns (bool) {
        uint256 amount = ERC20Wrapper.balanceOf(address(approvedToken), address(this)).mul(shares).div(totalShares);
        emit Withdrawal(receiver, amount);
        return ERC20Wrapper.transfer(address(approvedToken), receiver, amount);
    }
}
