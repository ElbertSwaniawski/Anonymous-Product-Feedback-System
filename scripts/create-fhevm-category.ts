#!/usr/bin/env ts-node

/**
 * create-fhevm-category - CLI tool to generate FHEVM category repositories
 *
 * Usage: ts-node scripts/create-fhevm-category.ts <category> [output-dir]
 *
 * Example: ts-node scripts/create-fhevm-category.ts voting ./my-voting-examples
 */

import * as fs from 'fs';
import * as path from 'path';

// Color codes for terminal output
enum Color {
  Reset = '\x1b[0m',
  Green = '\x1b[32m',
  Blue = '\x1b[34m',
  Yellow = '\x1b[33m',
  Red = '\x1b[31m',
  Cyan = '\x1b[36m',
}

function log(message: string, color: Color = Color.Reset): void {
  console.log(`${color}${message}${Color.Reset}`);
}

function error(message: string): never {
  log(`❌ Error: ${message}`, Color.Red);
  process.exit(1);
}

function success(message: string): void {
  log(`✅ ${message}`, Color.Green);
}

function info(message: string): void {
  log(`ℹ️  ${message}`, Color.Blue);
}

// Category configuration interface
interface CategoryConfig {
  description: string;
  examples: string[];
}

// Category definitions
const CATEGORIES_MAP: Record<string, CategoryConfig> = {
  'voting': {
    description: 'Voting system examples demonstrating privacy-preserving aggregation and access control',
    examples: ['encrypted-voting', 'public-voting'],
  },
};

function copyDirectoryRecursive(source: string, destination: string): void {
  if (!fs.existsSync(destination)) {
    fs.mkdirSync(destination, { recursive: true });
  }

  const items = fs.readdirSync(source);

  items.forEach(item => {
    const sourcePath = path.join(source, item);
    const destPath = path.join(destination, item);
    const stat = fs.statSync(sourcePath);

    if (stat.isDirectory()) {
      if (['node_modules', 'artifacts', 'cache', 'coverage', 'types', 'dist'].includes(item)) {
        return;
      }
      copyDirectoryRecursive(sourcePath, destPath);
    } else {
      fs.copyFileSync(sourcePath, destPath);
    }
  });
}

function generateCategoryReadme(categoryName: string, config: CategoryConfig, exampleCount: number): string {
  return `# FHEVM Category: ${categoryName}

${config.description}

This package contains ${exampleCount} complete FHEVM examples demonstrating key concepts.

## Quick Start

### Prerequisites

- **Node.js**: Version 20 or higher
- **npm**: Package manager

### Installation

\`\`\`bash
npm install
\`\`\`

### Running Tests

\`\`\`bash
npm run test
\`\`\`

### Compilation

\`\`\`bash
npm run compile
\`\`\`

## Available Contracts

${config.examples.map((ex) => `- **${ex}** - Located in contracts/`).join('\n')}

## Testing

Run all tests:

\`\`\`bash
npm test
\`\`\`

Run with coverage:

\`\`\`bash
npm run coverage
\`\`\`

## Deployment

Deploy to local network:

\`\`\`bash
npx hardhat node
npx hardhat deploy --network localhost
\`\`\`

Deploy to Sepolia:

\`\`\`bash
npx hardhat deploy --network sepolia
\`\`\`

## Learning Path

1. **Read the contracts** - Start with the contract files to understand the patterns
2. **Review the tests** - Test files demonstrate correct usage patterns
3. **Run locally** - Execute tests and modify values to experiment
4. **Deploy** - Try deploying to a test network

## Documentation

- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [Hardhat Documentation](https://hardhat.org/docs)

## License

BSD-3-Clause-Clear License

---

**Built with FHEVM by Zama**
`;
}

function createCategory(categoryName: string, outputDir: string): void {
  const rootDir = path.resolve(__dirname, '..');
  const templateDir = path.join(rootDir, 'base-template');

  // Check if category exists
  if (!CATEGORIES_MAP[categoryName]) {
    error(`Unknown category: ${categoryName}\n\nAvailable categories:\n${Object.keys(CATEGORIES_MAP).map(k => `  - ${k}`).join('\n')}`);
  }

  const category = CATEGORIES_MAP[categoryName];

  info(`Creating FHEVM category: ${categoryName}`);
  info(`Output directory: ${outputDir}`);

  // Step 1: Copy template
  log('\n📋 Step 1: Copying template...', Color.Cyan);
  if (fs.existsSync(outputDir)) {
    error(`Output directory already exists: ${outputDir}`);
  }
  copyDirectoryRecursive(templateDir, outputDir);
  success('Template copied');

  // Step 2: Copy contracts and tests
  log('\n📄 Step 2: Copying contracts and tests...', Color.Cyan);

  // Create contracts directory for category
  const contractsDir = path.join(outputDir, 'contracts');
  const testDir = path.join(outputDir, 'test');

  // Clear template files
  const templateContract = path.join(contractsDir, 'ExampleContract.sol');
  if (fs.existsSync(templateContract)) {
    fs.unlinkSync(templateContract);
  }

  const templateTests = fs.readdirSync(testDir).filter(f => f.endsWith('.ts'));
  templateTests.forEach(file => {
    fs.unlinkSync(path.join(testDir, file));
  });

  let contractCount = 0;

  // Copy all examples in the category
  category.examples.forEach((example) => {
    // Find contract file - search through the project for this example
    const possiblePaths = [
      path.join(rootDir, 'contracts', `${example.replace(/-/g, '')}.sol`),
      path.join(rootDir, 'contracts', `${example}.sol`),
      path.join(rootDir, `contracts/${example.charAt(0).toUpperCase()}${example.slice(1).replace(/-/g, '')}.sol`),
    ];

    let contractPath = null;
    for (const p of possiblePaths) {
      if (fs.existsSync(p)) {
        contractPath = p;
        break;
      }
    }

    if (!contractPath) {
      // Try common naming patterns
      const files = fs.readdirSync(path.join(rootDir, 'contracts')).filter(f => f.toLowerCase().includes(example.toLowerCase()));
      if (files.length > 0) {
        contractPath = path.join(rootDir, 'contracts', files[0]);
      }
    }

    if (contractPath && fs.existsSync(contractPath)) {
      const contractName = path.basename(contractPath);
      fs.copyFileSync(contractPath, path.join(contractsDir, contractName));
      success(`Copied contract: ${contractName}`);
      contractCount++;
    }
  });

  log('\n📝 Step 3: Generating README...', Color.Cyan);
  const readme = generateCategoryReadme(categoryName, category, contractCount);
  fs.writeFileSync(path.join(outputDir, 'README.md'), readme);
  success('README.md generated');

  // Final summary
  log('\n' + '='.repeat(60), Color.Green);
  success(`FHEVM category "${categoryName}" created successfully!`);
  log('='.repeat(60), Color.Green);

  log('\n📦 Next steps:', Color.Yellow);
  log(`  cd ${path.relative(process.cwd(), outputDir)}`);
  log('  npm install');
  log('  npm run compile');
  log('  npm run test');

  log('\n🎉 Happy coding with FHEVM!', Color.Cyan);
}

// Main execution
function main(): void {
  const args = process.argv.slice(2);

  if (args.length === 0 || args[0] === '--help' || args[0] === '-h') {
    log('FHEVM Category Generator', Color.Cyan);
    log('\nUsage: ts-node scripts/create-fhevm-category.ts <category> [output-dir]\n');
    log('Available categories:', Color.Yellow);
    Object.entries(CATEGORIES_MAP).forEach(([name, info]) => {
      log(`  ${name}`, Color.Green);
      log(`    ${info.description}`, Color.Reset);
      log(`    Examples: ${info.examples.join(', ')}`, Color.Reset);
    });
    log('\nExample:', Color.Yellow);
    log('  ts-node scripts/create-fhevm-category.ts voting ./my-voting-examples\n');
    process.exit(0);
  }

  const categoryName = args[0];
  const outputDir = args[1] || path.join(process.cwd(), 'output', `fhevm-category-${categoryName}`);

  createCategory(categoryName, outputDir);
}

main();
