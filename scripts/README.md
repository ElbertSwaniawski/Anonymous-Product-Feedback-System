# Automation Scripts

This directory contains TypeScript-based CLI tools for generating standalone FHEVM example repositories and documentation.

## Available Scripts

### create-fhevm-example.ts

Generates complete standalone repositories for individual examples.

**Usage:**

```bash
ts-node scripts/create-fhevm-example.ts <example-name> [output-dir]
```

**Examples:**

```bash
# Create encrypted voting example
ts-node scripts/create-fhevm-example.ts encrypted-voting ./my-voting-app

# Create public voting example
ts-node scripts/create-fhevm-example.ts public-voting ./my-public-voting
```

**What it does:**

- Clones the base Hardhat template
- Copies the specified contract and test files
- Updates configuration files
- Generates a README
- Creates deployment scripts

**Available Examples:**

- `encrypted-voting` - Privacy-preserving voting system with FHEVM
- `public-voting` - Reference public voting implementation

### create-fhevm-category.ts

Generates projects with multiple related examples from a category.

**Usage:**

```bash
ts-node scripts/create-fhevm-category.ts <category> [output-dir]
```

**Examples:**

```bash
# Create voting category project
ts-node scripts/create-fhevm-category.ts voting ./my-voting-examples
```

**What it does:**

- Creates a single project with multiple example contracts
- Copies all contracts from the specified category
- Includes all corresponding tests
- Generates unified README
- Perfect for learning multiple related concepts

**Available Categories:**

- `voting` - Multiple voting system implementations

### generate-docs.ts

Creates GitBook-formatted documentation from contracts and tests.

**Usage:**

```bash
ts-node scripts/generate-docs.ts <example-name> [options]
ts-node scripts/generate-docs.ts --all
```

**Examples:**

```bash
# Generate docs for encrypted voting
ts-node scripts/generate-docs.ts encrypted-voting

# Generate docs for all examples
ts-node scripts/generate-docs.ts --all
```

**What it does:**

- Extracts contract and test code
- Generates formatted Markdown
- Creates GitBook-compatible tabs
- Updates SUMMARY.md index
- Organizes by category

**Output:**

Documentation files are written to `docs/` directory with proper GitBook formatting.

## Development Workflow

### Adding New Examples

1. **Create contract** in `contracts/YourExample.sol`
   - Include detailed comments
   - Follow FHEVM patterns

2. **Create test** in `test/YourExample.ts`
   - Include success and failure cases
   - Use descriptive test names

3. **Update script configurations**
   - Add entry to `EXAMPLES_MAP` in `create-fhevm-example.ts`
   - Add entry to `EXAMPLES_CONFIG` in `generate-docs.ts`

4. **Generate documentation**
   ```bash
   ts-node scripts/generate-docs.ts your-example
   ```

5. **Test standalone repository**
   ```bash
   ts-node scripts/create-fhevm-example.ts your-example ./test-output
   cd test-output
   npm install && npm run compile && npm run test
   ```

### Adding New Categories

1. **Create category entries** in `create-fhevm-category.ts`
   - Define category name and description
   - List example names

2. **Test category generation**
   ```bash
   ts-node scripts/create-fhevm-category.ts your-category ./test-output
   cd test-output
   npm install && npm run test
   ```

## Common Tasks

### Update Dependencies

When FHEVM dependencies change:

1. Update `base-template/package.json`
2. Test by creating a few examples
3. Run comprehensive tests

```bash
# Update base template
cd base-template
npm update @fhevm/solidity

# Test example generation
ts-node scripts/create-fhevm-example.ts encrypted-voting ./test-voting
cd test-voting
npm install && npm test
```

### Regenerate All Documentation

```bash
ts-node scripts/generate-docs.ts --all
```

### Test All Examples

```bash
# Test individual examples
for example in encrypted-voting public-voting; do
  ts-node scripts/create-fhevm-example.ts $example ./test-output/$example
  cd ./test-output/$example
  npm install && npm test
  cd ../..
done
```

## Script Implementation Details

### Color Output

Scripts use terminal color codes for better readability:

- 🟢 Green - Success messages
- 🔵 Blue - Information messages
- 🟡 Yellow - Warnings and next steps
- 🔴 Red - Error messages
- 🔷 Cyan - Section headers

### Error Handling

Scripts validate:

- Example/category exists
- Source files exist
- Output directory doesn't exist
- File operations succeed

### File Copying

The `copyDirectoryRecursive` function:

- Copies entire directory structures
- Skips build artifacts (node_modules, cache, etc.)
- Preserves file structure

## Requirements

- **Node.js**: Version 20 or higher
- **TypeScript**: For ts-node execution
- **ts-node**: For running TypeScript scripts directly

## Installation

```bash
# Install ts-node globally for easier script execution
npm install -g ts-node typescript

# Or use npx
npx ts-node scripts/create-fhevm-example.ts --help
```

## License

BSD-3-Clause-Clear License

---

**Built with FHEVM by Zama**
