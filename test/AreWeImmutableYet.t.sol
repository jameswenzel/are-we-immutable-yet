// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/AreWeImmutableYet.sol";

contract AreWeBadOpcodeYet is AreWeImmutableYet {
    /**
     * known bad opcode
     */
    function areWeBadOpcodeYet() public returns (bool weAreImmutable) {
        ///@solidity memory-safe-assembly
        assembly {
            mstore(0, 0x600b5981380380925939f333EE)
            let addr := create2(0, 19, 13, 0)
            weAreImmutable := iszero(call(5010, addr, 0, 0, 0, 0, 0))
        }
    }

    function areWeNotHaltingYet4758() public returns (bool weAreImmutable) {
        ///@solidity memory-safe-assembly
        assembly {
            // if 0xFF opcode is still valid and does not stop execution, this will revert
            mstore(0, 0x600b5981380380925939f333503D3DFD)
            let addr := create2(0, 16, 16, 0)
            weAreImmutable := iszero(call(5010, addr, 0, 0, 0, 0, 0))
        }
    }

    function preDeploy() public returns (address addr) {
        ///@solidity memory-safe-assembly
        assembly {
            mstore(0, 0x600b5981380380925939f333FF)
            addr := create2(0, 19, 13, 0)
        }
    }
}

contract CounterTest is Test {
    AreWeImmutableYet public areWeImmutableYet;
    AreWeBadOpcodeYet public areWeBadOpcodeYet;

    function setUp() public {
        areWeImmutableYet = new AreWeImmutableYet();
        areWeBadOpcodeYet = new AreWeBadOpcodeYet();
    }

    function testAreWeImmutableYet() public {
        assertFalse(areWeImmutableYet.areWeImmutableYet());
        assertTrue(areWeBadOpcodeYet.areWeBadOpcodeYet());
    }

    function testAreWeImmutableYet4758() public {
        assertFalse(areWeBadOpcodeYet.areWeImmutableYet4758());
        assertTrue(areWeBadOpcodeYet.areWeNotHaltingYet4758());
    }

    function testHalting() public {
        assertFalse(areWeImmutableYet.areWeImmutableYet());
        address addr = areWeBadOpcodeYet.preDeploy();
        assertEq(addr, areWeBadOpcodeYet.targetAddress());
        assertTrue(areWeBadOpcodeYet.areWeImmutableYetHalting());
    }
}
