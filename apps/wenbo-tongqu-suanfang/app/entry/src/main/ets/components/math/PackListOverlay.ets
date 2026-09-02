import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { FilterChip, StudyPack } from '../../models/MathModels'
import { MathBizService } from '../../services/MathBizService'
import { MathLocalStore } from '../../services/MathLocalStore'

@Component
export struct PackListOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('mathHomeTick') @Watch('onTick') dataTick: number = 0
  @State packs: StudyPack[] = []
  @State title: string = '睡前十分钟'
  @State picked: string = 'add,sub'
  @State chips: FilterChip[] = []
  @State pendingId: string = ''
  onClose: () => void = () => {}
  onPractice: (pack: StudyPack) => void = (_p: StudyPack) => {}

  aboutToAppear(): void {
    this.chips = PackListOverlay.modeChips()
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private reload(): void {
    this.packs = MathLocalStore.snapshot().packs
  }

  private static pushChip(out: FilterChip[], id: string, label: string): void {
    const c = new FilterChip()
    c.id = id
    c.label = label
    out.push(c)
  }

  private static modeChips(): FilterChip[] {
    const out: FilterChip[] = []
    PackListOverlay.pushChip(out, 'add', '加法')
    PackListOverlay.pushChip(out, 'sub', '减法')
    PackListOverlay.pushChip(out, 'mul', '乘法')
    PackListOverlay.pushChip(out, 'div', '除法')
    PackListOverlay.pushChip(out, 'story', '应用题')
    PackListOverlay.pushChip(out, 'compare', '比大小')
    return out
  }

  private hasMode(id: string): boolean {
    const parts = this.picked.split(',')
    for (const p of parts) {
      if (p.trim() === id) {
        return true
      }
    }
    return false
  }

  private toggle(id: string): void {
    const next: string[] = []
    for (const p of this.picked.split(',')) {
      const t = p.trim()
      if (t.length > 0 && t !== id) {
        next.push(t)
      }
    }
    if (!this.hasMode(id) && next.length < 4) {
      next.push(id)
    }
    let joined = ''
    for (const x of next) {
      joined = joined.length > 0 ? `${joined},${x}` : x
    }
    this.picked = joined
  }

  private async save(): Promise<void> {
    if (this.picked.length === 0) {
      return
    }
    const pack = new StudyPack()
    pack.id = MathLocalStore.newId('pk')
    pack.title = this.title.trim().length > 0 ? this.title.trim() : '我的题单'
    pack.modes = this.picked
    pack.createdAt = MathLocalStore.today()
    await MathBizService.savePack(pack)
    this.reload()
  }

  private async remove(id: string): Promise<void> {
    await MathBizService.removePack(id)
    this.pendingId = ''
    this.reload()
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44).height(44).justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text('我的题单')
          .fontSize(Theme.type.title3).fontWeight(FontWeight.Medium)
          .layoutWeight(1).textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%').padding({ left: Theme.space.s2, right: Theme.space.s2, top: Theme.space.s2 })

      Column({ space: Theme.space.s3 }) {
        TextInput({ text: this.title, placeholder: '题单名称，如睡前十分钟' })
          .width('100%').height(44)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .onChange((v: string) => { this.title = v })
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.chips, (c: FilterChip) => {
            Text(c.label)
              .fontSize(Theme.type.caption)
              .fontColor(this.hasMode(c.id) ? '#FFFFFF' : Theme.colors().textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.hasMode(c.id) ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => this.toggle(c.id))
          }, (c: FilterChip) => c.id)
        }
        .width('100%')
        AppButton({ label: '保存题单', onTap: (): void => { void this.save() } })
      }
      .padding({ left: Theme.space.s6, right: Theme.space.s6 })
      .width('100%')

      if (this.packs.length === 0) {
        Column() {
          AppEmpty({ title: '还没有专题', description: '勾选 2～4 种题型，保存后就能反复练' })
        }
        .layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.packs, (p: StudyPack) => {
            ListItem() {
              Column({ space: Theme.space.s1 }) {
                Text(p.title)
                  .fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(p.modes)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Row({ space: Theme.space.s3 }) {
                  Text('去练习').fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .onClick(() => this.onPractice(p))
                  Text('删除').fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .onClick(() => { this.pendingId = p.id })
                }
              }
              .width('100%').padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .margin({ bottom: Theme.space.s3 })
            }
          }, (p: StudyPack) => p.id)
        }
        .layoutWeight(1).padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s6 })
        .scrollBar(BarState.Off)
      }
      if (this.pendingId.length > 0) {
        Column({ space: Theme.space.s3 }) {
          Text('删除这份题单？')
            .fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium)
            .width('100%')
          AppButton({
            label: '确认删除',
            variant: 'danger',
            onTap: (): void => { void this.remove(this.pendingId) }
          })
          AppButton({ label: '取消', variant: 'secondary', onTap: () => { this.pendingId = '' } })
        }
        .padding(Theme.space.s5)
        .margin({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s6 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
      }
    }
    .width('100%').height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
