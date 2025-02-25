import '@typechain/hardhat'
import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-waffle'
import 'prettier-plugin-solidity'
import 'hardhat-tracer'
import 'hardhat-gas-reporter'
import 'solidity-coverage'
import { HardhatUserConfig } from 'hardhat/config'
import 'hardhat-contract-sizer'
import '@primitivefi/hardhat-dodoc'

const config: HardhatUserConfig = {
  dodoc: {
    runOnCompile: false,
    include: [
      'PositionRenderer',
      'PrimitiveManager',
      'CashManager',
      'ERC1155Permit',
      'ManagerBase',
      'MarginManager',
      'Multicall',
      'PositionManager',
      'Reentrancy',
      'SelfPermit',
      'SwapManager',
      'ICashManager',
      'IERC1155Permit',
      'IManagerBase',
      'IMarginManager',
      'IMulticall',
      'IPositionRenderer',
      'IPrimitiveManager',
      'ISelfPermit',
      'ISwapManager',
      'EngineAddress',
      'HexStrings',
      'Margin',
      'TransferHelper',
    ],
    templatePath: './docusaurus.sqrl',
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    },
  },
  solidity: {
    version: '0.8.6',
    settings: {
      optimizer: {
        enabled: true,
        runs: 400,
      },
    },
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: false,
    disambiguatePaths: false,
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 100,
    enabled: false,
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
}

export default config
