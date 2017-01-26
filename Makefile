include pgxntool/base.mk

# Temporary hack
testdeps: $(wildcard test/*/*.sql) # Be careful not to include directories in this
