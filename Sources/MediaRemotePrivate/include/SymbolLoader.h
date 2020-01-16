//
//  SymbolLoader.h
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2019  Xander Deng. Licensed under GPLv3.
//

// MARK: Helper

#define SLStringify_(s) #s
#define SLStringify(s) SLStringify_(s)

// MARK: Naming

#define SLStorage(symbol) symbol##_

// MARK: - Storage

#define SLDeclareVariable(symbol, type) \
    extern _Nullable type SLStorage(symbol)

#define SLDefineVariable(symbol, type) \
    _Nullable type SLStorage(symbol)

#define SLDeclareFunction(symbol, return_t, args_t...) \
    return_t (* _Nullable SLStorage(symbol))(args_t)

#define SLDefineFunction(symbol, return_t, args_t...) \
    return_t (* _Nullable SLStorage(symbol))(args_t)

// MARK: - Load

#define SLLoad(handle, symbol) \
    SLStorage(symbol) = dlsym(handle, SLStringify(symbol))
