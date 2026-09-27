"""
Matugen Pygments Style for Aider
Dynamically synchronized with the desktop Matugen palette.
"""
from pygments.style import Style
from pygments.token import (
    Comment, Error, Generic, Keyword, Literal, Name, Number, Operator,
    Other, Punctuation, String, Text, Token, Whitespace
)

class MatugenStyle(Style):
    name = 'matugen'
    background_color = '#17130b'
    highlight_color = '#231f17'
    line_number_color = '#999080'
    line_number_background_color = '#17130b'

    styles = {
        Token: '#eae1d4',
        Whitespace: '',
        Error: '#ffb4ab',
        Other: '',

        Comment: 'italic #999080',
        Comment.Multiline: 'italic #999080',
        Comment.Preproc: 'bold #d7c5a0',
        Comment.Single: 'italic #999080',
        Comment.Special: 'bold italic #d7c5a0',

        Keyword: 'bold #e7c26c',
        Keyword.Constant: 'bold #afcfab',
        Keyword.Declaration: 'bold #e7c26c',
        Keyword.Namespace: 'bold #d7c5a0',
        Keyword.Pseudo: '#e7c26c',
        Keyword.Reserved: 'bold #e7c26c',
        Keyword.Type: 'nobold #d7c5a0',

        Operator: '#e7c26c',
        Operator.Word: 'bold #e7c26c',

        Punctuation: '#eae1d4',

        Name: '#eae1d4',
        Name.Attribute: '#d7c5a0',
        Name.Builtin: '#d7c5a0',
        Name.Builtin.Pseudo: '#d7c5a0',
        Name.Class: 'bold #e7c26c',
        Name.Constant: '#afcfab',
        Name.Decorator: 'bold #afcfab',
        Name.Entity: '#d7c5a0',
        Name.Exception: 'bold #ffb4ab',
        Name.Function: 'bold #e7c26c',
        Name.Property: '#d7c5a0',
        Name.Label: 'italic #d7c5a0',
        Name.Namespace: '#d7c5a0',
        Name.Other: '#eae1d4',
        Name.Tag: 'bold #e7c26c',
        Name.Variable: '#eae1d4',
        Name.Variable.Class: '#eae1d4',
        Name.Variable.Global: '#eae1d4',
        Name.Variable.Instance: '#eae1d4',

        Number: '#afcfab',
        Number.Float: '#afcfab',
        Number.Hex: '#afcfab',
        Number.Integer: '#afcfab',
        Number.Integer.Long: '#afcfab',
        Number.Oct: '#afcfab',

        Literal: '#afcfab',
        Literal.Date: '#afcfab',

        String: '#afcfab',
        String.Backtick: '#afcfab',
        String.Char: '#afcfab',
        String.Doc: 'italic #999080',
        String.Double: '#afcfab',
        String.Escape: 'bold #d7c5a0',
        String.Heredoc: '#afcfab',
        String.Interpol: 'bold #d7c5a0',
        String.Other: '#afcfab',
        String.Regex: '#d7c5a0',
        String.Single: '#afcfab',
        String.Symbol: '#afcfab',

        Generic: '',
        Generic.Deleted: '#ffb4ab',
        Generic.Emph: 'italic',
        Generic.Error: '#ffb4ab',
        Generic.Heading: 'bold #e7c26c',
        Generic.Inserted: '#afcfab',
        Generic.Output: '#999080',
        Generic.Prompt: 'bold #e7c26c',
        Generic.Strong: 'bold',
        Generic.EmphStrong: 'bold italic',
        Generic.Subheading: 'bold #d7c5a0',
        Generic.Traceback: '#ffb4ab',
    }
