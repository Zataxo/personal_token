const {expect} = require("chai");
// const { ethers } = require("hardhat");
const hre = require("hardhat");
describe("ZataxToken Contract", function(){
    // let Token;
    let zataxToken;
    let owner;
    let add1;
    let add2;
    let maxCap = 100000000;
    let blockReward = 50;
    beforeEach(async function() {
        zataxToken = await ethers.deployContract("TestToken",[maxCap,blockReward]);
        [owner,add1,add2] = await ethers.getSigners();
    });
    it("Should Set The Right Owner",async function(){
        const ownerAddress = await zataxToken.owner();
        // console.log(await zataxToken.owner());
        expect(ownerAddress).to.equal(owner.address);
    });
    it("Total supply is assigned to the owner balance",async function(){
        const tokenSupply = await zataxToken.totalSupply();
        const ownerBalance = await zataxToken.balanceOf(owner.address);
        expect(tokenSupply).to.equal(ownerBalance);
    });
    it("Address one balance should be zero",async function(){
        const addressOneBalance = await zataxToken.balanceOf(add1);
        expect(addressOneBalance).to.equal(0);
    })
    it("Should transfer tokens between account",async function(){
        // transfer from the owner to address1
        await zataxToken.transfer(add1,50);
        const addressOneBalance = await zataxToken.balanceOf(add1.address)
        expect(addressOneBalance).to.equal(50);
        // transfering from address1 to address 2
        await zataxToken.connect(add1).transfer(add2.address,20);
        const add2Balance = await zataxToken.balanceOf(add2.address);
        expect(add2Balance).to.equal(20);
    })
    it("Should not allow to transfer from empty account",async function(){
        const ownerBalance = await zataxToken.balanceOf(owner.address);
        await expect(zataxToken.connect(add1).transfer(owner.address,1)).to.be.reverted;
        expect(ownerBalance).to.equal(await zataxToken.balanceOf(owner.address));
    })
    it("Should set the max cap supply to the token",async function(){
        const tokenMaxSupply = await zataxToken.cap();
        expect(maxCap).to.equal(Number(hre.ethers.formatEther(tokenMaxSupply)));
    })
})
