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
            const wordCount = text.split(/\s+/).filter(word => word.length > 0).length;

            statusBarItem.text = `Tokens: ${tokenCount} | Lines: ${lineCount} | Words: ${wordCount}`;
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
