import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppTextInputField } from '../components/design-system/AppTextInputField'
import { InsightFav, LibraryAction, MoodOption, ThemeSpaceOption } from '../models/TrainingModels'
import { UserProfile } from '../models/WorkoutModels'
import { DateHelper } from '../services/DateHelper'
import { TrainingStore } from '../services/TrainingStore'
import { WorkoutStore } from '../services/WorkoutStore'

@Component
export struct MineArchiveExtras {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('fitDataEpoch') @Watch('onDataEpochChange') fitDataEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onToast: (msg: string) => void = () => {}
  @State energyKey: string = ''
  @State driveKey: string = ''
  @State bodyNote: string = ''
  @State insightTitle: string = ''
  @State insightBody: string = ''
  @State favActions: LibraryAction[] = []
  @State favs: InsightFav[] = []
  @State themeKey: string = ''
  @State profile: UserProfile = new UserProfile()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataEpochChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.profile = await WorkoutStore.loadProfile()
    this.themeKey = this.profile.themeSpaceKey
    const note = await TrainingStore.loadTodayNote()
    this.energyKey = note.energy
    this.driveKey = note.drive
    this.bodyNote = note.text
    this.favActions = await TrainingStore.favActions()
    this.favs = await TrainingStore.loadFavs()
  }

  private async saveNote(): Promise<void> {
    const n = await TrainingStore.loadTodayNote()
    n.dateKey = DateHelper.todayKey()
    n.energy = this.energyKey
    n.drive = this.driveKey
    n.text = this.bodyNote.trim()
    await TrainingStore.saveNote(n)
    this.onToast('今日状态已记下')
  }

  private async pickTheme(opt: ThemeSpaceOption): Promise<void> {
    this.themeKey = opt.key
    this.profile.themeSpaceKey = opt.key
    await WorkoutStore.saveProfile(this.profile)
    AppStorage.setOrCreate('pendingTag', opt.tag)
    this.onToast(`已选主题「${opt.label}」，写日志时可带上标签`)
  }

  private async saveInsight(): Promise<void> {
    const title = this.insightTitle.trim()
    const body = this.insightBody.trim()
    if (title.length === 0 || body.length === 0) {
      this.onToast('请填写标题和心得')
      return
    }
    const f = new InsightFav()
    f.id = TrainingStore.newId()
    f.title = title
    f.body = body
    await TrainingStore.saveFav(f)
    this.insightTitle = ''
    this.insightBody = ''
    this.favs = await TrainingStore.loadFavs()
    this.onToast('已收入训练灵感库')
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Column({ space: Theme.space.s2 }) {
        Text('身体状态笔记')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text('只记主观感觉，不读取健康传感器。')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Text('今日状态')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(MoodOption.energy(), (o: MoodOption) => {
            Text(o.label)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.energyKey === o.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.energyKey === o.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.energyKey = o.key })
          }, (o: MoodOption) => `e-${o.key}`)
        }
        .width('100%')
        Text('训练动力')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(MoodOption.drive(), (o: MoodOption) => {
            Text(o.label)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.driveKey === o.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.driveKey === o.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.driveKey = o.key })
          }, (o: MoodOption) => `d-${o.key}`)
        }
        .width('100%')
        AppTextInputField({
          text: this.bodyNote,
          placeholder: '今天的训练感受（可选）',
          compact: true,
          onChange: (v: string): void => { this.bodyNote = v }
        })
        AppButton({
          label: '保存今日笔记',
          variant: 'secondary',
          onTap: (): void => { void this.saveNote() }
        })
      }
      .width('100%')
      .padding(Theme.space.cardPadding)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)

      Column({ space: Theme.space.s2 }) {
        Text('训练主题空间')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        ForEach(ThemeSpaceOption.all(), (opt: ThemeSpaceOption) => {
          Column({ space: 4 }) {
            Text(opt.label)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
            Text(opt.hint)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(Theme.space.s3)
          .backgroundColor(this.themeKey === opt.key ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { void this.pickTheme(opt) })
        }, (opt: ThemeSpaceOption) => opt.key)
      }
      .width('100%')

      Column({ space: Theme.space.s2 }) {
        Text('训练灵感库')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        AppTextInputField({
          text: this.insightTitle,
          placeholder: '例如：适合自己的晨间训练',
          compact: true,
          onChange: (v: string): void => { this.insightTitle = v }
        })
        AppTextInputField({
          text: this.insightBody,
          placeholder: '方法总结或自我经验',
          compact: true,
          onChange: (v: string): void => { this.insightBody = v }
        })
        AppButton({
          label: '收入灵感库',
          variant: 'secondary',
          onTap: (): void => { void this.saveInsight() }
        })
        ForEach(this.favs, (f: InsightFav) => {
          Column({ space: 4 }) {
            Text(f.title)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textPrimary)
            Text(f.body)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .maxLines(3)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(Theme.space.s3)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.md)
        }, (f: InsightFav) => f.id)
      }
      .width('100%')
      .padding(Theme.space.cardPadding)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)

      if (this.favActions.length > 0) {
        Column({ space: Theme.space.s2 }) {
          Text('图鉴收藏')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.favActions, (a: LibraryAction) => {
            Text(a.name)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }, (a: LibraryAction) => a.id)
        }
        .width('100%')
      }
    }
    .width('100%')
  }
}
