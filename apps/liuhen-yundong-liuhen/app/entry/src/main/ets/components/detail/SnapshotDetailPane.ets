import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { WeeklySnapshot, WorkoutTypeOption } from '../../models/WorkoutModels'
import { WorkoutStore } from '../../services/WorkoutStore'

@Component
export struct SnapshotDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop snapshot: WeeklySnapshot = new WeeklySnapshot()
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  @State reflection: string = ''
  @State pinned: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.hydrate()
  }

  private async hydrate(): Promise<void> {
    this.reflection = this.snapshot.reflection
    this.pinned = this.snapshot.isPinned()
    const saved = await WorkoutStore.loadSnapshots()
    for (const s of saved) {
      if (s.id === this.snapshot.id) {
        this.reflection = s.reflection
        this.pinned = s.pinned === 1
        this.snapshot.pinned = s.pinned
        this.snapshot.reflection = s.reflection
      }
    }
  }

  private async persistPin(v: boolean): Promise<void> {
    this.pinned = v
    this.snapshot.pinned = v ? 1 : 0
    await WorkoutStore.saveSnapshotNote(
      this.snapshot.id,
      this.reflection.trim(),
      v ? 1 : 0,
      this.snapshot.insight
    )
    this.onSaved()
    this.showToast(v ? '已置顶这一周' : '已取消置顶')
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async saveReflection(): Promise<void> {
    await WorkoutStore.saveSnapshotNote(
      this.snapshot.id,
      this.reflection.trim(),
      this.pinned ? 1 : 0,
      this.snapshot.insight
    )
    this.snapshot.reflection = this.reflection.trim()
    this.snapshot.pinned = this.pinned ? 1 : 0
    this.onSaved()
    this.showToast('本周复盘已保存到本机')
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onClose() })

      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('周报印记')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.empty_calm'))
                .width('100%')
                .height(160)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Column() {
                Blank()
                Column({ space: 4 }) {
                  Text(this.snapshot.weekLabel)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                  Text(this.pinned ? '已置顶的一周' : '本周运动复盘')
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['#00000000', 0], ['#CC1A1A2E', 1]]
                })
              }
              .width('100%')
              .height(160)
            }

            Column({ space: Theme.space.s3 }) {
              this.MetaRow('运动次数', `${this.snapshot.count} 次`)
              this.MetaRow('合计时长', `${this.snapshot.totalMinutes} 分钟`)
              this.MetaRow('主要类型', this.snapshot.topType.length > 0 ?
                WorkoutTypeOption.labelFor(this.snapshot.topType) : '—')
            }
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            Column({ space: Theme.space.s2 }) {
              Text('智慧摘要')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
              Text(this.snapshot.insight)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .lineHeight(22)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            Column({ space: Theme.space.s2 }) {
              Text('我的复盘（写下来才算留下这一周）')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              TextInput({ text: this.reflection, placeholder: '这周最想记住的一点…' })
                .onChange((v: string): void => { this.reflection = v })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            Row() {
              Text(this.pinned ? '已置顶到留痕页' : '置顶这一周')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
              Blank()
              Toggle({ type: ToggleType.Switch, isOn: this.pinned })
                .selectedColor(Theme.colors().brandPrimary)
                .onChange((v: boolean): void => { void this.persistPin(v) })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            AppButton({
              label: '保存复盘',
              variant: 'primary',
              onTap: (): void => { void this.saveReflection() }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('92%')
      .backgroundColor(Theme.colors().surfacePage)
      .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.88)')
          .borderRadius(Theme.radius.pill)
          .position({ top: 48 })
          .zIndex(90)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(62)
  }

  @Builder
  MetaRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
      Blank()
      Text(value)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
    }
    .width('100%')
  }
}
