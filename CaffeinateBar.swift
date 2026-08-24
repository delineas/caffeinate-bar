import Cocoa

private let keepDisplayKey = "keepDisplayAwake"
private let caffeinatePath = "/usr/bin/caffeinate"

private let presets: [(String, Int)] = [
    ("Indefinido", 0),
    ("15 minutos", 15),
    ("30 minutos", 30),
    ("1 hora", 60),
    ("2 horas", 120),
    ("5 horas", 300),
    ("8 horas (jornada)", 480),
]

/// Aviso visual cuando queda poco. nil = sin límite, nunca avisa.
let warningSeconds = 600
func isWarning(_ remaining: Int?) -> Bool {
    guard let r = remaining else { return false }
    return r <= warningSeconds
}

/// Segundos -> "m:ss" o "h:mm:ss".
func clock(_ seconds: Int) -> String {
    let s = max(0, seconds)
    let (h, m, sec) = (s / 3600, (s % 3600) / 60, s % 60)
    return h > 0 ? String(format: "%d:%02d:%02d", h, m, sec) : String(format: "%d:%02d", m, sec)
}

final class Controller: NSObject, NSMenuDelegate {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private var task: Process?
    private var ticker: Timer?
    private var endDate: Date?
    private var minutes = 0   // 0 = indefinido

    private var keepDisplay: Bool {
        get { UserDefaults.standard.bool(forKey: keepDisplayKey) }
        set { UserDefaults.standard.set(newValue, forKey: keepDisplayKey) }
    }

    private var isActive: Bool { task?.isRunning == true }
    private var remaining: Int? { endDate.map { Int($0.timeIntervalSinceNow.rounded()) } }

    override init() {
        super.init()
        menu.delegate = self
        item.menu = menu
        render()
    }

    // MARK: - caffeinate

    private func start() {
        stop()
        let p = Process()
        p.executableURL = URL(fileURLWithPath: caffeinatePath)
        // -w <pid nuestro>: si la app muere (crash incluido) caffeinate se va con ella, sin huérfanos.
        var args = ["-i", "-m", "-s", "-u", "-w", String(ProcessInfo.processInfo.processIdentifier)]
        if keepDisplay { args.insert("-d", at: 0) }
        p.arguments = args
        p.terminationHandler = { [weak self] finished in
            DispatchQueue.main.async {
                guard let self = self, self.task === finished else { return }
                self.reset()
            }
        }
        do {
            try p.run()
        } catch {
            NSSound.beep()
            return
        }
        task = p
        if minutes > 0 {
            endDate = Date(timeIntervalSinceNow: Double(minutes) * 60)
            let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in self?.tick() }
            // .common: la cuenta atrás sigue viva con el menú desplegado.
            RunLoop.main.add(t, forMode: .common)
            ticker = t
        }
        render()
    }

    private func stop() {
        task?.terminate()
        reset()
    }

    private func reset() {
        task = nil
        ticker?.invalidate()
        ticker = nil
        endDate = nil
        render()
    }

    private func tick() {
        if let left = remaining, left <= 0 { stop(); return }
        render()
        liveStatus?.title = status()
    }

    // MARK: - barra

    private func render() {
        let image = NSImage(systemSymbolName: isActive ? "cup.and.saucer.fill" : "cup.and.saucer",
                            accessibilityDescription: "Caffeinate")
        image?.isTemplate = true
        item.button?.image = image
        item.button?.contentTintColor = (isActive && isWarning(remaining)) ? .systemOrange : nil
        item.button?.toolTip = status()
    }

    private func status() -> String {
        guard isActive else { return "Inactivo — el Mac puede dormirse" }
        guard let left = remaining else { return "Activo — sin límite" }
        return "Activo — quedan \(clock(left))"
    }

    // MARK: - menú

    private weak var liveStatus: NSMenuItem?

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        liveStatus = menu.addItem(withTitle: status(), action: nil, keyEquivalent: "")
        let toggle = menu.addItem(withTitle: isActive ? "Desactivar" : "Activar",
                                  action: #selector(toggleActive), keyEquivalent: "")
        toggle.target = self

        menu.addItem(.separator())
        let header = NSMenuItem(title: "Duración", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        for (title, mins) in presets {
            let i = menu.addItem(withTitle: title, action: #selector(pickPreset(_:)), keyEquivalent: "")
            i.target = self
            i.tag = mins
            i.state = (isActive && minutes == mins) ? .on : .off
            i.indentationLevel = 1
        }

        menu.addItem(.separator())
        let d = menu.addItem(withTitle: "Mantener la pantalla encendida",
                             action: #selector(toggleDisplay), keyEquivalent: "")
        d.target = self
        d.state = keepDisplay ? .on : .off

        menu.addItem(.separator())
        let q = menu.addItem(withTitle: "Salir", action: #selector(quit), keyEquivalent: "q")
        q.target = self
    }

    @objc private func toggleActive() {
        isActive ? stop() : start()
    }

    @objc private func pickPreset(_ sender: NSMenuItem) {
        minutes = sender.tag
        start()
    }

    @objc private func toggleDisplay() {
        keepDisplay.toggle()
        if isActive { start() }   // relanzar con los flags nuevos
    }

    @objc private func quit() {
        stop()
        NSApp.terminate(nil)
    }
}

private func selfTest() -> Int32 {
    precondition(clock(0) == "0:00")
    precondition(clock(-5) == "0:00")
    precondition(clock(59) == "0:59")
    precondition(clock(600) == "10:00")
    precondition(clock(3661) == "1:01:01")
    precondition(clock(28800) == "8:00:00")
    precondition(isWarning(nil) == false)      // indefinido nunca avisa
    precondition(isWarning(601) == false)
    precondition(isWarning(600) == true)
    precondition(isWarning(0) == true)

    let p = Process()
    p.executableURL = URL(fileURLWithPath: caffeinatePath)
    p.arguments = ["-i", "-t", "5"]
    do { try p.run() } catch {
        print("FAIL: no se pudo lanzar caffeinate: \(error)")
        return 1
    }
    usleep(300_000)
    guard p.isRunning else { print("FAIL: caffeinate murió al arrancar (flags inválidos)"); return 1 }
    p.terminate()
    p.waitUntilExit()
    guard !p.isRunning else { print("FAIL: caffeinate sigue vivo tras terminate"); return 1 }
    print("OK: formato y umbral de aviso correctos, caffeinate arranca y se detiene")
    return 0
}

if CommandLine.arguments.contains("--selftest") { exit(selfTest()) }

let app = NSApplication.shared
app.setActivationPolicy(.accessory)   // sin icono en el Dock
let controller = Controller()
app.run()
