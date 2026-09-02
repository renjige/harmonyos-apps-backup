import { Theme } from '../design-system/Theme'
import { ObserveTheme } from '../../models/GrowthModels'
import { SenseOption } from '../../models/EssayModels'
import { DateHelper } from '../../services/DateHelper'
import { GrowthStore } from '../../services/GrowthStore'
import { EssayStore } from '../../services/EssayStore'
import { EssayDataNotifier } from '../../services/EssayDataNotifier'

@Component
export struct ThemeEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop themeId: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  @State title: string = ''
  @State senseKey: string = ''
  @State targetCount: number = 5
  @State toastText: string = ''
  private senses: SenseOption[] = SenseOption.all()
  private targets: number[] = [3, 5, 7, 10]

  aboutToAppear(): void {
    if (this.themeId.length === 0) {
      this.senseKey = 'sound'
    }
    void this.boot()
  }

  private async boot(): Promise<void> {
    if (this.themeId.length === 0) {
      return
    }
    const found = await GrowthStore.findTheme(this.themeId)
    if (found !== undefined) {
      this.title = found.title
      this.senseKey = found.senseKey
      this.targetCount = found.targetCount
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private async persist(): Promise<void> {
    const name = this.title.trim()
    if (name.length === 0) {
      this.showToast('请填写专题名称')
      return
    }
    const today = DateHelper.todayKey()
    const start = DateHelper.addDaysKey(today, -29)
    const end = DateHelper.addDaysKey(today, 29)
    let theme = ObserveTheme.create(name, this.senseKey, this.targetCount, start, end)
    if (this.themeId.length > 0) {
      const found = await GrowthStore.findTheme(this.themeId)
      if (found !== undefined) {
        theme = found
        theme.title = name
        theme.senseKey = this.senseKey
        theme.targetCount = this.targetCount
      }
    }
    await GrowthStore.saveTheme(theme)
    const essays = await EssayStore.loadAll()
    await GrowthStore.relinkEssayThemes(essays)
    await EssayStore.persistAll(essays)
    AppStorage.setOrCreate('themeEpoch', (AppStorage.get<number>('themeEpoch') ?? 0) + 1)
    EssayDataNotifier.bump()
    this.showToast('专题已创建，写对应感官观察即可计进度')
    setTimeout((): void => { this.onSaved() }, 400)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text(this.themeId.length > 0 ? '编辑观察专题' : '新建观察专题')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Text('取消')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => { this.onClose() })
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('这个专题约束你本段时间只练一种感官，写满目标篇数即完成。')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.title, placeholder: '例如：这个月只写声音' })
              .width('100%')
              .height(48)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .padding(Theme.space.s3)
              .onChange((v: string) => { this.title = v })
            Text('主感官')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              Text('不限')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.senseKey.length === 0 ? '#FFFFFF' : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.senseKey.length === 0 ? '#1A2A3A' : Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => { this.senseKey = '' })
              ForEach(this.senses, (s: SenseOption) => {
                Text(s.label)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.senseKey === s.key ? '#FFFFFF' : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.senseKey === s.key ? '#1A2A3A' : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.senseKey = s.key })
              }, (s: SenseOption) => s.key)
            }
            .width('100%')
            Text('目标篇数')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Row({ space: Theme.space.s2 }) {
              ForEach(this.targets, (n: number) => {
                Text(`${n}`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.targetCount === n ? '#FFFFFF' : Theme.colors().textPrimary)
                  .textAlign(TextAlign.Center)
                  .layoutWeight(1)
                  .padding({ top: 10, bottom: 10 })
                  .backgroundColor(this.targetCount === n ? '#1A2A3A' : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.sm)
                  .onClick((): void => { this.targetCount = n })
              }, (n: number) => `t_${n}`)
            }
            .width('100%')
            Text('保存专题')
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .textAlign(TextAlign.Center)
              .width('100%')
              .padding({ top: 12, bottom: 12 })
              .backgroundColor('#1A2A3A')
              .border({ width: 1, color: '#C9A96E' })
              .borderRadius(Theme.radius.md)
              .onClick((): void => { void this.persist() })
            Blank().height(Theme.space.s8)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.body)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('#1A2A3A')
          .borderRadius(Theme.radius.pill)
          .position({ x: '12%', y: 44 })
          .zIndex(90)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(75)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
