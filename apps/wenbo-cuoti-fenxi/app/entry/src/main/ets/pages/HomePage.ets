import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CatalogListCard } from '../components/wrong/CatalogListCard'
import { EntryListCard } from '../components/wrong/EntryListCard'
import { AnalyzeEngine, CatalogOptions } from '../services/AnalyzeEngine'
import { WrongBizService } from '../services/WrongBizService'
import { WrongDetailNav } from '../services/WrongDetailNav'
import { WrongMedia } from '../services/WrongMedia'
import { CatalogItem, CatalogKind, SubjectOption, WrongEntry } from '../models/WrongModels'
import { AuthService } from '../services/AuthService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '文波错题析'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State entries: WrongEntry[] = []
  @State subjects: CatalogItem[] = []
  @State query: string = ''
  @State subjectFilter: string = 'all'
  @State loading: boolean = false
  onRequireAuth: () => void = () => {}
  onOpenMessages: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.subjects = await WrongBizService.loadSubjects()
    this.entries = await WrongBizService.loadEntries()
    this.loading = false
  }

  private visibleEntries(): WrongEntry[] {
    const out: WrongEntry[] = []
    const q = this.query.trim()
    for (const e of this.entries) {
      if (this.subjectFilter !== 'all' && e.subjectCode !== this.subjectFilter) {
        continue
      }
      if (q.length > 0 && e.stem.indexOf(q) < 0 && e.knowledgeTag.indexOf(q) < 0) {
        continue
      }
      out.push(e)
    }
    return out
  }

  private startCapture(mode: string): void {
    if (!AuthService.requireAuth('create')) {
      this.onRequireAuth()
      return
    }
    WrongDetailNav.openCapture(mode, '')
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Row() {
            Column({ space: 4 }) {
              Text(this.appName)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text('今天，先记下这一道')
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Column() {
              AppIcon({ name: 'message', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick(() => this.onOpenMessages())
          }
          .width('100%')

          Stack({ alignContent: Alignment.BottomStart }) {
            Image(WrongMedia.resource('hero_desk'))
              .width('100%')
              .height(210)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(210)
              .linearGradient({
                angle: 180,
                colors: [['rgba(11,31,74,0.15)', 0], ['rgba(11,31,74,0.82)', 1]]
              })
            Column({ space: Theme.space.s3 }) {
              Text('把错过的题变成下周复习清单')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .width('100%')
              Row({ space: Theme.space.s3 }) {
                Text('拍照录入')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.sm)
                  .onClick(() => this.startCapture('photo'))
                Text('手动录入')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                  .border({ width: 1, color: '#FFFFFF' })
                  .borderRadius(Theme.radius.sm)
                  .onClick(() => this.startCapture('manual'))
              }
            }
            .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
          }
          .width('100%')
          .borderRadius(Theme.radius.md)
          .clip(true)

          Stack({ alignContent: Alignment.Start }) {
            Image(WrongMedia.resource('banner_review'))
              .width('100%')
              .height(72)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(72)
              .linearGradient({
                angle: 90,
                colors: [['rgba(11,31,74,0.55)', 0], ['rgba(11,31,74,0.2)', 1]]
              })
            Text('复习时先看错因，再看答案')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .padding({ left: Theme.space.s4 })
          }
          .width('100%')
          .borderRadius(Theme.radius.sm)
          .clip(true)

          Row({ space: Theme.space.s3 }) {
            this.stat('今日', `${AnalyzeEngine.todayCount(this.entries)}`)
            this.stat('待复习', `${AnalyzeEngine.pendingCount(this.entries)}`)
            this.stat('已掌握', `${AnalyzeEngine.masteredCount(this.entries)}`)
          }
          .width('100%')

          TextInput({ text: this.query, placeholder: '搜索题目或知识点' })
            .onChange((v: string) => { this.query = v })
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .width('100%')

          Scroll() {
            Row({ space: Theme.space.s2 }) {
              Text('全部')
                .fontSize(Theme.type.caption)
                .fontColor(this.subjectFilter === 'all' ?
                  Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.subjectFilter === 'all' ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.subjectFilter = 'all' })
              ForEach(CatalogOptions.subjects(), (s: SubjectOption) => {
                Text(s.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.subjectFilter === s.code ?
                    Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.subjectFilter === s.code ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .onClick(() => { this.subjectFilter = s.code })
              }, (s: SubjectOption) => s.code)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .width('100%')

          Text('最近错题')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          if (this.visibleEntries().length === 0) {
            AppEmpty({
              title: this.entries.length === 0 ? '还没有错题' : '没有匹配的错题',
              description: this.entries.length === 0 ?
                '点上方录入第一道。登录后才会保存到你的错题本。' : '试试换一个学科或清空搜索。',
              actionLabel: '手动录入',
              onAction: () => this.startCapture('manual')
            })
          } else {
            ForEach(this.visibleEntries(), (e: WrongEntry) => {
              EntryListCard({
                entry: e,
                onOpen: () => WrongDetailNav.openEntry(e.id)
              })
            }, (e: WrongEntry) => e.id)
          }

          Text('学科导学')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Scroll() {
            Row({ space: Theme.space.s3 }) {
              ForEach(this.subjects, (s: CatalogItem) => {
                CatalogListCard({
                  item: s,
                  onOpen: () => WrongDetailNav.openCatalog(CatalogKind.SUBJECT, s.id)
                })
              }, (s: CatalogItem) => s.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .width('100%')
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: Theme.space.s10
        })
        .constraintSize({ maxWidth: 720 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  stat(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
