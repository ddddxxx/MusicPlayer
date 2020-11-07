//
//  SymbolLoader.h
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
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
