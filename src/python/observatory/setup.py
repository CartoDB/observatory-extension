"""
CartoDB Spatial Analysis Python Library
See:
https://github.com/CartoDB/crankshaft
"""

from setuptools import setup, find_packages

setup(
    name='observatory',

    version='0.0.1',

    description='CARTO Observatory Python Library',

    url='https://github.com/CartoDB/observatory-extension',

    author='Research and Data - CARTO',
    author_email='john@carto.com',

    license='MIT',

    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Mapping comunity',
        'Topic :: Maps :: Mapping Tools',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 2.7',
    ],

    keywords='maps mapping tools spatial data',

    packages=find_packages(exclude=['contrib', 'docs', 'tests']),

    extras_require={
        'dev': ['unittest'],
        'test': ['unittest', 'nose', 'mock'],
    },

    # The choice of component versions is dictated by what's
    # provisioned in the production servers.
    # IMPORTANT NOTE: please don't change this line. Instead issue a ticket to systems for evaluation.
    install_requires=[],
    #install_requires=['overpass==0.5.6'],

    requires=[],
    #requires=['overpass'],

    #test_suite='test'
)
