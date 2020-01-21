pragma solidity 0.5.3;

import "./oz/Ownable.sol";
import "./oz/IERC20.sol";
import "./oz/SafeMath.sol";
//import "./ERC20Wrapper.sol";
import "./SafeERC20.sol";

contract SafeGuildBank is Ownable {
    using SafeMath for uint256;

    IERC20 public approvedToken; // approved token contract reference

    event Withdrawal(address indexed receiver, address indexed tokenAddress, uint256 amount);

    function withdraw(address receiver, uint256 shares, uint256 totalShares, IERC20[] memory approvedTokens) public onlyOwner returns (bool) {
        for (uint256 i = 0; i < approvedTokens.length; i++) {
            uint256 amount = fairShare(approvedTokens[i].balanceOf(address(this)), shares, totalShares);
            emit Withdrawal(receiver, address(approvedTokens[i]), amount);
            require(SafeERC20.safeTransfer(approvedTokens[i],receiver, amount));
        }
        return true;
    }

    function withdrawToken(IERC20 token, address receiver, uint256 amount) public onlyOwner returns (bool) {
        require(token.balanceOf(address(this)) >= amount);
        emit Withdrawal(receiver, address(token), amount);
        return SafeERC20.safeTransfer(token, receiver, amount);
    }

    function fairShare(uint256 balance, uint256 shares, uint256 totalShares) internal pure returns (uint256) {
        require(totalShares != 0);

        if (balance == 0) { return 0; }

        uint256 prod = balance.mul(shares);

        if (prod.div(balance) == shares) { // no overflow in multiplication above?
            return prod.div(totalShares);
        }

        return (balance.div(totalShares)).mul(shares);
    }
}
