import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { MoodMultiSelector } from '../components/dream/MoodMultiSelector'
import { TagChipBar } from '../components/slip/TagChipBar'
import { NoteItem } from '../models/SlipModels'
import { MoodCatalog } from '../services/MoodCatalog'
import { SlipDateUtil } from '../services/SlipDateUtil'
import { SlipMedia } from '../services/SlipMedia'
import { SlipStore } from '../services/SlipStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '梦隅札'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State bodyText: string = ''
  @State emotionsCsv: string = 'calm'
  @State tags: string[] = []
  @State sleepHours: string = '8'
  @State toastText: string = ''
  @State voiceHint: string = ''
  onOpenLibrary: () => void = () => {}

  aboutToAppear(): void {
    this.resetForm()
  }

  onRefreshTokenChange(): void {
    this.resetForm()
  }

  private resetForm(): void {
    this.bodyText = ''
    this.emotionsCsv = 'calm'
    this.tags = []
    this.sleepHours = '8'
  }

  private greeting(): string {
    const h = new Date().getHours()
    if (h >= 5 && h < 12) {
      return '晨光好，昨夜梦见了什么？'
    }
    if (h >= 18 || h < 5) {
      return '今夜好梦，此刻你梦见了什么？'
    }
    return '午后静思，记下一段梦境碎片'
  }

  private toggleEmotion(id: string): void {
    const current = MoodCatalog.parseEmotions(this.emotionsCsv)
    const next: string[] = []
    let removed = false
    for (const e of current) {
      if (e === id) {
        removed = true
      } else {
        next.push(e)
      }
    }
    if (!removed) {
      next.push(id)
    }
    if (next.length === 0) {
      next.push('calm')
    }
    this.emotionsCsv = next.join('|')
  }

  private toggleTag(tag: string): void {
    const next: string[] = []
    let removed = false
    for (const t of this.tags) {
      if (t === tag) {
        removed = true
      } else {
        next.push(t)
      }
    }
    if (!removed) {
      next.push(tag)
    }
    this.tags = next
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private onVoiceTap(): void {
    this.voiceHint = '语音输入需麦克风权限；也可直接键入文字记录梦境。'
    this.showToast('请口述梦境内容，或直接文字输入')
    setTimeout((): void => { this.voiceHint = '' }, 3200)
  }

  private async saveDream(): Promise<void> {
    if (this.bodyText.trim().length === 0) {
      this.showToast('写一段梦境再保存吧')
      return
    }
    const now = new Date()
    const item = new NoteItem()
    item.id = SlipDateUtil.newId()
    item.createdAt = Date.now()
    item.updatedAt = Date.now()
    item.noteDate = SlipDateUtil.toIso(now)
    item.timeLabel = SlipDateUtil.timeLabel(now)
    item.title = this.bodyText.trim().length > 16 ?
      this.bodyText.trim().substring(0, 16) : this.bodyText.trim()
    item.body = this.bodyText.trim()
    item.mood = this.emotionsCsv
    item.tagsCsv = this.tags.join(',')
    item.cardTemplate = this.sleepHours.trim().length > 0 ? this.sleepHours.trim() : '8'
    item.coverKey = this.tags.length > 0 ? SlipMedia.forTag(this.tags[0]) : 'hero_moon_window'
    await SlipStore.save(item)
    AppStorage.setOrCreate('noteRefresh', (AppStorage.get<number>('noteRefresh') ?? 0) + 1)
    this.showToast('梦境已收入札记')
    this.resetForm()
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(SlipMedia.cover('hero_moon_window'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column()
              .width('100%')
              .height(72)
              .borderRadius({ bottomLeft: Theme.radius.xl, bottomRight: Theme.radius.xl })
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,26,46,0)', 0], ['rgba(26,26,46,0.82)', 1]]
              })
            Column({ space: 4 }) {
              Text(SlipDateUtil.homeDate(new Date()))
                .fontSize(Theme.type.caption)
                .fontColor('#F5F0E8')
              Text(this.greeting())
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F5F0E8')
            }
            .padding({ left: Theme.space.s4, bottom: Theme.space.s4, right: Theme.space.s4 })
          }
          .width('100%')

          TextArea({ text: this.bodyText, placeholder: '此刻，你梦见了什么？' })
            .width('100%')
            .height(220)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .padding(Theme.space.s4)
            .onChange((v: string) => { this.bodyText = v })

          if (this.voiceHint.length > 0) {
            Text(this.voiceHint)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }

          Row({ space: Theme.space.s3 }) {
            Column() {
              AppIcon({ name: 'message', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
            }
            .width(52)
            .height(52)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.onVoiceTap() })
            Text('语音转文字（需麦克风权限）')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .layoutWeight(1)
          }
          .width('100%')

          Text('梦境标签')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          TagChipBar({
            choices: MoodCatalog.defaultTags(),
            selectedCsv: this.tags.join(','),
            onToggle: (tag: string): void => { this.toggleTag(tag) }
          })

          Text('情绪感受（可多选）')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          MoodMultiSelector({
            selectedCsv: this.emotionsCsv,
            onToggle: (id: string): void => { this.toggleEmotion(id) }
          })

          Row({ space: Theme.space.s3 }) {
            Text('睡眠时长')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            TextInput({ text: this.sleepHours, placeholder: '8' })
              .width(72)
              .height(40)
              .type(InputType.Number)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.sleepHours = v })
            Text('小时')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Blank()
          }
          .width('100%')
          .padding({ bottom: Theme.space.s10 })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      Column() {
        AppButton({ label: '保存梦境', onTap: (): void => { void this.saveDream() } })
      }
      .padding({ right: Theme.space.pageX, bottom: Theme.space.s6, left: Theme.space.pageX })
      .margin({ bottom: 8 })

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s4 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
