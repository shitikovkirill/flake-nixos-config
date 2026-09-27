# Configuration file for Sphinx documentation builder
# For the full list of options, see the Sphinx documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import os
import sys
from datetime import datetime

# Add parent directory to path
sys.path.insert(0, os.path.abspath('..'))

# Project information
project = 'flake-nixos-config'
copyright = f'{datetime.now().year}, Kirill Shitikov'
author = 'Kirill Shitikov'
release = '1.0'

# General configuration
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.intersphinx',
    'sphinx.ext.todo',
    'sphinx.ext.viewcode',
    'myst_parser',  # For Markdown support
]

# Source file extensions
source_suffix = {
    '.rst': 'restructuredtext',
    '.md': 'markdown',
}

# Master toc tree document
master_doc = 'index'

# List of patterns, relative to source directory, that should be ignored
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store', '.git']

# Pygments style
pygments_style = 'sphinx'
pygments_dark_style = 'monokai'

# HTML output options
html_theme = 'furo'
html_title = f'{project} Documentation'
html_logo = None
html_favicon = None

html_theme_options = {
    'light_css_variables': {
        'color-brand-primary': '#0066cc',
        'color-brand-content': '#0066cc',
    },
    'dark_css_variables': {
        'color-brand-primary': '#2684ff',
        'color-brand-content': '#2684ff',
    },
}

html_static_path = ['_static']
html_show_sourcelink = False
html_show_sphinx = False

# Markdown configuration
myst_enable_extensions = [
    'colon_fence',
    'tasklist',
    'deflist',
]

# Intersphinx mapping
intersphinx_mapping = {}

# Todo extension options
todo_include_todos = True

# Language and locale options
language = 'en'
locale_dirs = ['locale/']
gettext_compact = False
