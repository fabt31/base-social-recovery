import { ethers } from "ethers";
export async function getGuardianStatus(walletAddress: string, guardianAddress: string, provider: ethers.JsonRpcProvider) {
  const abi = ["function guardians(bytes32) view returns (bool)", "function threshold() view returns (uint256)", "function guardianCount() view returns (uint256)"];
  const wallet = new ethers.Contract(walletAddress, abi, provider);
  const guardianHash = ethers.keccak256(ethers.solidityPacked(["address"], [guardianAddress]));
  const [isGuardian, threshold, count] = await Promise.all([wallet.guardians(guardianHash), wallet.threshold(), wallet.guardianCount()]);
  return { isGuardian, threshold: Number(threshold), guardianCount: Number(count) };
}
