// SPDX-License-Identifier: MIT
pragma solidity 0.8.18; // Q: Is this the correct compiler version?

/*
 * @author not-so-secure-dev
 * @title PasswordStore
 * @notice This contract allows you to store a private password that others won't be able to see. 
 * You can update your password at any time.
 */
contract PasswordStore {
       // I - naming convention could be more clear ie 'error PasswordStore__NotOwner();'
    error PasswordStore__NotOwner();

    address private s_owner;

    string private s_password;//This is not secure!

    event SetNewPassword();

    constructor() {
        s_owner = msg.sender;
    }

    /*
     * @notice This function allows only the owner to set a new password.
     * @param newPassword The new password to set.
     */
      // @Audit - High - any user can set a password.
    function setPassword(string memory newPassword) external {
        if(msg.sender != s_owner) {
            revert PasswordStore__NotOwner();
        }
        s_password = newPassword;
        emit SetNewPassword();
    }

    /*
     * @notice This allows only the owner to retrieve the password.
     * @param newPassword The new password to set.
     */
    function getPassword() external view returns (string memory) {
        if (msg.sender != s_owner) {
            revert PasswordStore__NotOwner();
        }
        return s_password;
    }
}
