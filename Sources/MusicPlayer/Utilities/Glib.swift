//
//  Glib.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if os(Linux)

import Foundation
import playerctl

func gproperty<T, R>(_ ptr: UnsafeMutablePointer<T>, name: String, transform: (UnsafeMutablePointer<GValue>) -> R) -> R {
    ptr.withMemoryRebound(to: GObject.self, capacity: 1) {
        var value = GValue()
        g_object_get_property($0, name, &value)
        return transform(&value)
    }
}


class GEventLoop {
    
    static private(set) var loop: OpaquePointer? /* GMainLoop* */ = nil
    static private(set) var running = false
    
    static func start() {
        if !running {
            running = true
            Thread.detachNewThread {
                Thread.current.name = "GMainLoop"
                loop = g_main_loop_new(g_main_context_get_thread_default(), 0)
                g_main_loop_run(loop)
            }
        }
    }
    
    static func quit() {
        if let loop = Self.loop {
            running = false
            g_main_loop_quit(loop)
            Self.loop = nil
        }
    }
}

#endif
