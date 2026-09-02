import { Theme } from '../components/design-system/Theme'
import { AppButton, AppGradientButton } from '../components/design-system/AppButton'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ChallengeListCard } from '../components/sport/ChallengeListCard'
import { SportChallenge } from '../models/SportModels'
import { ChallengeStore } from '../services/ChallengeStore'
import { SportRecordService } from '../services/SportRecordService'
import { SportDetailNav } from '../services/SportDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct ChallengePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: SportChallenge[] = []
  @State showForm: boolean = false
  @State title: string = ''
  @State sportType: string = '全部'
  @State targetSessions: string = '8'
  @State startDate: string = ''
  @State endDate: string = ''
  @State note: string = ''
  @State formError: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onDataChanged: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
    this.startDate = SportRecordService.todayKey()
    this.endDate = SportRecordService.addDays(this.startDate, 14)
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.items = ChallengeStore.list()
  }

  private openForm(): void {
    if (!AuthService.requireAuth('create')) {
      this.onRequireAuth()
      return
    }
    this.title = ''
    this.sportType = '全部'
    this.targetSessions = '8'
    this.startDate = SportRecordService.todayKey()
    this.endDate = SportRecordService.addDays(this.startDate, 14)
    this.note = ''
    this.formError = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async submit(): Promise<void> {
    const n = parseInt(this.targetSessions, 10)
    if (this.title.trim().length < 2) {
      this.formError = '请填写挑战名称'
      return
    }
    if (isNaN(n) || n < 1) {
      this.formError = '目标次数至少为 1'
      return
    }
    if (this.endDate < this.startDate) {
      this.formError = '结束日期不能早于开始日期'
      return
    }
    const c = new SportChallenge()
    c.id = `ch_${Date.now()}`
    c.title = this.title.trim()
    c.sportType = this.sportType
    c.targetSessions = n
    c.startDate = this.startDate
    c.endDate = this.endDate
    c.note = this.note.trim()
    c.status = 'active'
    c.createdAt = new Date().toISOString()
    await ChallengeStore.save(c)
    this.closeForm()
    this.reload()
    this.onDataChanged()
  }

  private types(): string[] {
    const list = ['全部']
    for (const t of SportRecordService.sportTypes()) {
      list.push(t)
    }
    return list
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Column({ space: Theme.space.s2 }) {
            Text('自建赛季挑战')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text('设定日期与次数，训练记录会自动计入进度——不是系统日历，而是你自己的赛季。')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')

          AppGradientButton({
            label: '新建挑战',
            onTap: (): void => {
              this.openForm()
            }
          })

          if (this.items.length === 0) {
            AppEmpty({
              title: '还没有挑战',
              description: '例如「两周跑步 8 次」。完成后可在详情标记结束。',
              actionLabel: '立即创建',
              onAction: (): void => {
                this.openForm()
              }
            })
          } else {
            ForEach(this.items, (c: SportChallenge) => {
              ChallengeListCard({
                item: c,
                onTap: (): void => {
                  SportDetailNav.openChallenge(c.id)
                }
              })
            }, (c: SportChallenge) => c.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s6,
          bottom: Theme.space.s10 + 80
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .onAppear(() => {
        this.reload()
      })

      if (this.showForm) {
        this.FormSheet()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FormSheet() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Text('新建挑战')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => {
            this.closeForm()
          })
      }
      .width('100%')
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          this.FieldRow('挑战名称', this.title, (v: string): void => {
            this.title = v
          }, '如 两周晨跑赛季')
          Column({ space: Theme.space.s2 }) {
            Text('计入的运动类型')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.types(), (t: string) => {
                Text(t)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.sportType === t ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.sportType === t ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => {
                    this.sportType = t
                  })
              }, (t: string) => t)
            }
            .width('100%')
          }
          this.FieldRow('目标次数', this.targetSessions, (v: string): void => {
            this.targetSessions = v
          })
          AppDatePickerField({
            label: '开始日期',
            value: this.startDate,
            onChange: (v: string): void => {
              this.startDate = v
            }
          })
          AppDatePickerField({
            label: '结束日期',
            value: this.endDate,
            onChange: (v: string): void => {
              this.endDate = v
            }
          })
          this.FieldRow('说明', this.note, (v: string): void => {
            this.note = v
          }, '想用这个赛季解决什么问题')
          if (this.formError.length > 0) {
            Text(this.formError)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().danger)
          }
          AppButton({
            label: '保存挑战',
            onTap: (): void => {
              void this.submit()
            }
          })
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
    .padding({ top: Theme.space.s6 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(40)
  }

  @Builder
  FieldRow(label: string, value: string, onChange: (v: string) => void, placeholder: string = '') {
    Column({ space: Theme.space.s2 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      TextInput({ text: value, placeholder: placeholder })
        .onChange((v: string) => {
          onChange(v)
        })
        .fontColor(Theme.colors().textPrimary)
        .placeholderColor(Theme.colors().textSecondary)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.md)
        .padding(Theme.space.s3)
        .border({ width: 1, color: Theme.colors().strokeHairline })
    }
    .width('100%')
  }
}
