#!/bin/bash

# Set up variables
EXT_NAME="VS Code Extension to Count Tokens, Words and Lines"
EXT_IDENTIFIER="vs-code-extension-to-count-tokens--words-and-lines"
EXT_DESCRIPTION="Extension that counts all the lines, words and AI Tokens in the current file and show the results in the statusbar with an option to not count comments."
PACKAGE_MANAGER="npm"

# Create the project directory
mkdir "$EXT_NAME"
cd "$EXT_NAME" || exit

# Create package.json
cat <<EOL > package.json
{
  "name": "$EXT_IDENTIFIER",
  "displayName": "$EXT_NAME",
  "description": "$EXT_DESCRIPTION",
  "version": "0.0.1",
  "engines": {
    "vscode": "^1.50.0"
  },
  "categories": [
    "Other"
  ],
  "activationEvents": [
    "onCommand:extension.showTokenLineWordCount"
  ],
  "main": "src/extension.js",
  "contributes": {
    "commands": [
      {
        "command": "extension.showTokenLineWordCount",
        "title": "Show Token, Line, and Word Count"
      }
    ]
  },
  "scripts": {
    "vscode:prepublish": "$PACKAGE_MANAGER run package"
  },
  "devDependencies": {
    "@types/vscode": "^1.50.0",
    "typescript": "^4.0.3",
    "gpt-3-encoder": "^1.1.4"
  },
  "dependencies": {}
}
EOL

# Create jsconfig.json for type checking
cat <<EOL > jsconfig.json
{
  "compilerOptions": {
    "checkJs": true
  }
}
EOL

# Initialize a git repository
git init

# Create the extension source folder
mkdir src

# Create the extension entry point (extension.js)
cat <<EOL > src/extension.js
const vscode = require('vscode');
const { encode } = require('gpt-3-encoder');

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
    let statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
    statusBarItem.command = "extension.showTokenLineWordCount";

    const updateCounts = () => {
        const editor = vscode.window.activeTextEditor;
        if (editor) {
            const document = editor.document;
            const text = document.getText();

            const tokenCount = encode(text).length;
            const lineCount = document.lineCount;
            const wordCount = text.split(/\\s+/).filter(word => word.length > 0).length;

            statusBarItem.text = \`Tokens: \${tokenCount} | Lines: \${lineCount} | Words: \${wordCount}\`;
            statusBarItem.show();
        } else {
            statusBarItem.hide();
        }
    };

    let disposable = vscode.commands.registerCommand('extension.showTokenLineWordCount', () => {
        updateCounts();
    });

    context.subscriptions.push(disposable);
    context.subscriptions.push(statusBarItem);

    vscode.workspace.onDidChangeTextDocument(() => {
        updateCounts();
    });

    vscode.window.onDidChangeActiveTextEditor(() => {
        updateCounts();
    });

    updateCounts();
}

function deactivate() {}

module.exports = {
    activate,
    deactivate
};
EOL

# Initialize npm
$PACKAGE_MANAGER init -y

# Install necessary dependencies
$PACKAGE_MANAGER install gpt-3-encoder

# Set up .vscodeignore to avoid bundling unnecessary files
cat <<EOL > .vscodeignore
node_modules
.vscode
.git
EOL

# Set up README.md
cat <<EOL > README.md
# $EXT_NAME

$EXT_DESCRIPTION
EOL

# Notify the user
echo "VS Code extension '$EXT_NAME' created successfully!"
