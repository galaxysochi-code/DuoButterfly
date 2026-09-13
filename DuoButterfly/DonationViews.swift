import SwiftUI
import AppKit

/// Thin banner under the window header inviting people to thank the developer.
struct ThanksBanner: View {
    @Bindable var model: AppModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 16))
                .foregroundStyle(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text(tr("Нравится DUO Butterfly?")).font(.system(size: 13, weight: .semibold))
                Text(tr("Скажите спасибо разработчику, он очень старался."))
                    .font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer(minLength: 8)
            Button {
                model.showsDonations = true
            } label: {
                Label(tr("Сказать спасибо"), systemImage: "heart").padding(.horizontal, 2)
            }
            .buttonStyle(.glassProminent)
            .tint(.pink)
            Button { model.hideThanksBanner() } label: {
                Image(systemName: "xmark").font(.system(size: 11, weight: .semibold))
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            .help(tr("Скрыть до завтра"))
            .accessibilityLabel(tr("Скрыть до завтра"))
        }
        .padding(.horizontal, 20).padding(.vertical, 9)
        .background(LinearGradient(colors: [Color.pink.opacity(0.12), Color.purple.opacity(0.10)],
                                   startPoint: .leading, endPoint: .trailing))
    }
}

struct DonationSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white, LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(tr("Спасибо, что пользуетесь DUO Butterfly")).font(.system(size: 17, weight: .bold))
                    Text(tr("Если приложение вам нравится, поддержите разработчика любой суммой в криптовалюте."))
                        .foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                }
            }
            VStack(spacing: 8) {
                ForEach(Donations.available) { DonationRow(wallet: $0) }
            }
            Label(tr("Отправляйте монеты только в указанной сети. Перевод в другой сети может быть потерян."),
                  systemImage: "exclamationmark.triangle.fill")
                .font(.system(size: 12)).foregroundStyle(.orange)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Spacer()
                Button(tr("Готово")) { dismiss() }.keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 560)
    }
}

private struct DonationRow: View {
    let wallet: DonationWallet
    @State private var copied = false
    @State private var showsQR = false

    var body: some View {
        HStack(spacing: 12) {
            CoinLogo(kind: wallet.logo, badge: wallet.badge)
                .frame(width: 32, height: 32).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(verbatim: wallet.asset).font(.system(size: 13, weight: .semibold))
                    Text(verbatim: wallet.network)
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(.quaternary, in: Capsule())
                }
                Text(verbatim: wallet.address)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1).truncationMode(.middle)
                    .textSelection(.enabled)
            }
            Spacer(minLength: 8)
            Button { showsQR.toggle() } label: { Image(systemName: "qrcode") }
                .help(tr("Показать QR-код"))
                .accessibilityLabel(tr("Показать QR-код"))
                .popover(isPresented: $showsQR, arrowEdge: .trailing) {
                    VStack(spacing: 10) {
                        if let image = Donations.qrCode(for: wallet.paymentURI, size: 200) {
                            Image(nsImage: image).interpolation(.none)
                                .padding(10).background(Color.white, in: RoundedRectangle(cornerRadius: 10))
                                .accessibilityLabel(tr("QR-код адреса %@", wallet.asset))
                        }
                        Text(verbatim: "\(wallet.asset) · \(wallet.network)").font(.system(size: 12, weight: .semibold))
                        Text(tr("Отсканируйте камерой кошелька на телефоне — перевод откроется с этим адресом."))
                            .font(.system(size: 11)).foregroundStyle(.secondary)
                            .multilineTextAlignment(.center).frame(width: 220)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                }
            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(wallet.address, forType: .string)
                copied = true
                Task { try? await Task.sleep(for: .seconds(2)); copied = false }
            } label: {
                Label(copied ? tr("Скопировано") : tr("Скопировать"), systemImage: copied ? "checkmark" : "doc.on.doc")
                    .frame(minWidth: 110)
            }
            .accessibilityLabel(tr("Скопировать адрес %@", wallet.asset))
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.primary.opacity(0.06)))
    }
}

/// Vector coin marks drawn after the projects' official logos.
struct CoinLogo: View {
    enum Kind: String, Hashable, Sendable, Decodable { case bitcoin, ethereum, usdc, tether, ton, gram, solana }
    let kind: Kind
    var badge: Kind? = nil

    var body: some View {
        mark(kind)
            .overlay(alignment: .bottomTrailing) {
                if let badge {
                    GeometryReader { geometry in
                        let side = geometry.size.width * 0.46
                        mark(badge)
                            .frame(width: side, height: side)
                            .overlay(Circle().strokeBorder(Color(nsColor: .controlBackgroundColor), lineWidth: max(1.5, side * 0.12)))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .offset(x: side * 0.18, y: side * 0.18)
                    }
                }
            }
    }

    private func mark(_ kind: Kind) -> some View {
        Canvas { context, size in
            let s = min(size.width, size.height)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func polygon(_ points: [(CGFloat, CGFloat)]) -> Path {
                var path = Path()
                path.move(to: p(points[0].0, points[0].1))
                for point in points.dropFirst() { path.addLine(to: p(point.0, point.1)) }
                path.closeSubpath()
                return path
            }
            let circle = Path(ellipseIn: CGRect(x: 0, y: 0, width: s, height: s))
            switch kind {
            case .bitcoin:
                context.fill(circle, with: .color(Color(red: 0.969, green: 0.576, blue: 0.102)))
                var symbol = context.resolve(Text("\u{20BF}").font(.system(size: s * 0.66, weight: .bold)).foregroundStyle(.white))
                symbol.shading = .color(.white)
                context.translateBy(x: s / 2, y: s / 2)
                context.rotate(by: .degrees(14))
                context.draw(symbol, at: .zero, anchor: .center)
            case .ethereum:
                context.fill(circle, with: .color(Color(red: 0.384, green: 0.494, blue: 0.918)))
                let white = Color.white
                context.fill(polygon([(0.5, 0.14), (0.5, 0.405), (0.275, 0.505)]), with: .color(white.opacity(0.95)))
                context.fill(polygon([(0.5, 0.14), (0.725, 0.505), (0.5, 0.405)]), with: .color(white.opacity(0.62)))
                context.fill(polygon([(0.275, 0.505), (0.5, 0.405), (0.5, 0.64)]), with: .color(white.opacity(0.62)))
                context.fill(polygon([(0.5, 0.405), (0.725, 0.505), (0.5, 0.64)]), with: .color(white.opacity(0.25)))
                context.fill(polygon([(0.275, 0.55), (0.5, 0.685), (0.5, 0.86)]), with: .color(white.opacity(0.95)))
                context.fill(polygon([(0.5, 0.685), (0.725, 0.55), (0.5, 0.86)]), with: .color(white.opacity(0.62)))
            case .tether:
                context.fill(circle, with: .color(Color(red: 0.149, green: 0.631, blue: 0.482)))
                context.fill(Path(roundedRect: CGRect(x: 0.24 * s, y: 0.22 * s, width: 0.52 * s, height: 0.125 * s), cornerRadius: 0.012 * s), with: .color(.white))
                context.fill(Path(CGRect(x: 0.435 * s, y: 0.33 * s, width: 0.13 * s, height: 0.47 * s)), with: .color(.white))
                context.stroke(Path(ellipseIn: CGRect(x: 0.2 * s, y: 0.435 * s, width: 0.6 * s, height: 0.15 * s)), with: .color(.white), lineWidth: 0.05 * s)
            case .usdc:
                if let url = Bundle.main.url(forResource: "usdc", withExtension: "svg"),
                   let image = NSImage(contentsOf: url) {
                    context.draw(context.resolve(Image(nsImage: image).resizable()), in: CGRect(x: 0, y: 0, width: s, height: s))
                } else {
                    context.fill(circle, with: .color(Color(red: 0.243, green: 0.451, blue: 0.769)))
                }
            case .gram:
                let blue = Color(red: 0.345, green: 0.627, blue: 0.933)
                context.fill(circle, with: .color(blue))
                let gem = polygon([(0.366, 0.305), (0.634, 0.305), (0.775, 0.465), (0.5, 0.74), (0.225, 0.465)])
                context.fill(gem, with: .color(.white))
                context.stroke(gem, with: .color(.white), style: StrokeStyle(lineWidth: 0.05 * s, lineJoin: .round))
                let c = p(0.5, 0.475), r = 0.1 * s
                var sparkle = Path()
                sparkle.move(to: CGPoint(x: c.x, y: c.y - r))
                sparkle.addQuadCurve(to: CGPoint(x: c.x + r, y: c.y), control: CGPoint(x: c.x + r * 0.18, y: c.y - r * 0.18))
                sparkle.addQuadCurve(to: CGPoint(x: c.x, y: c.y + r), control: CGPoint(x: c.x + r * 0.18, y: c.y + r * 0.18))
                sparkle.addQuadCurve(to: CGPoint(x: c.x - r, y: c.y), control: CGPoint(x: c.x - r * 0.18, y: c.y + r * 0.18))
                sparkle.addQuadCurve(to: CGPoint(x: c.x, y: c.y - r), control: CGPoint(x: c.x - r * 0.18, y: c.y - r * 0.18))
                context.fill(sparkle, with: .color(blue))
            case .ton:
                context.fill(circle, with: .color(Color(red: 0.345, green: 0.627, blue: 0.933)))
                var outline = Path()
                outline.move(to: p(0.285, 0.29))
                outline.addLine(to: p(0.715, 0.29))
                outline.addLine(to: p(0.5, 0.735))
                outline.closeSubpath()
                outline.move(to: p(0.5, 0.29))
                outline.addLine(to: p(0.5, 0.735))
                context.stroke(outline, with: .color(.white), style: StrokeStyle(lineWidth: 0.065 * s, lineCap: .round, lineJoin: .round))
            case .solana:
                context.fill(circle, with: .color(.black))
                let gradient = Gradient(colors: [Color(red: 0.557, green: 0.318, blue: 0.965), Color(red: 0.263, green: 0.541, blue: 0.788), Color(red: 0.035, green: 0.8, blue: 0.608)])
                let shading = GraphicsContext.Shading.linearGradient(gradient, startPoint: p(0.25, 0.72), endPoint: p(0.75, 0.28))
                context.fill(polygon([(0.33, 0.285), (0.765, 0.285), (0.67, 0.375), (0.235, 0.375)]), with: shading)
                context.fill(polygon([(0.235, 0.455), (0.67, 0.455), (0.765, 0.545), (0.33, 0.545)]), with: shading)
                context.fill(polygon([(0.33, 0.625), (0.765, 0.625), (0.67, 0.715), (0.235, 0.715)]), with: shading)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
