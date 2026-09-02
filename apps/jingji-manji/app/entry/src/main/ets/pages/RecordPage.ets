import { Theme } from '../components/design-system/Theme'
import { AppButton, AppGradientButton } from '../components/design-system/AppButton'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { SportListCard } from '../components/sport/SportListCard'
import { SportDraft, SportRecord } from '../models/SportModels'
import { SportStore } from '../services/SportStore'
import { SportRecordService } from '../services/SportRecordService'
import { SportModelClone } from '../services/SportModelClone'
import { SportDetailNav } from '../services/SportDetailNav'
import { AuthService } from '../services/AuthService'
import { TagService, RecordFilter, TagItem } from '../services/TagService'
import { GlassPanel } from '../components/design-system/GlassPanel'
import { SectionHeader } from '../components/design-system/SectionHeader'
import { SelectChip } from '../components/design-system/SelectChip'

@Component
export struct RecordPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: SportRecord[] = []
  @State recent: SportRecord | null = null
  @State showForm: boolean = false
  @State draft: SportDraft = SportRecordService.emptyDraft()
  @State formError: string = ''
  @State toastText: string = ''
  @State isRecording: boolean = false
  @State elapsedSec: number = 0
  @State searchKeyword: string = ''
  @State filterSport: string = ''
  @State filterTag: string = ''
  @State tagOptions: TagItem[] = []
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop @Watch('onSportEpochChange') sportEpoch: number = 0
  @StorageLink('sportDataEpoch') @Watch('onSportDataEpochChange') sportDataEpoch: number = 0
  @StorageLink('recordFormRequest') @Watch('onRecordFormRequest') recordFormRequest: number = 0
  onRequireAuth: () => void = () => {}
  onDataChanged: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  onSportDataEpochChange(): void {
    this.reload()
  }

  onSportEpochChange(): void {
    this.reload()
  }

  onRecordFormRequest(): void {
    this.applyRecordPrefill()
  }

  private applyRecordPrefill(): void {
    const payload = SportDetailNav.consumeRecordPrefill()
    if (payload.templateCategory.length > 0) {
      const tpl = SportRecordService.templateForCategory(payload.templateCategory)
      if (payload.dateKey.length > 0) {
        tpl.recordDate = payload.dateKey
      }
      this.openTemplate(tpl)
      return
    }
    if (payload.dateKey.length > 0) {
      if (!AuthService.requireAuth('create')) {
        this.onRequireAuth()
        return
      }
      this.draft = SportRecordService.emptyDraft()
      this.draft.recordDate = payload.dateKey
      this.formError = ''
      this.showForm = true
      AppStorage.setOrCreate('tabBarHidden', true)
    }
  }

  private reload(): void {
    this.tagOptions = TagService.allTags()
    this.items = this.filteredItems()
    const rec = SportStore.recent(1)
    this.recent = rec.length > 0 ? rec[0] : null
  }

  private filteredItems(): SportRecord[] {
    const f = new RecordFilter()
    f.keyword = this.searchKeyword.trim()
    f.sportType = this.filterSport
    f.tag = this.filterTag
    return TagService.filter(f)
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => {
      this.toastText = ''
    }, 2800)
  }

  private openForm(prefillMin: number): void {
    if (!AuthService.requireAuth('create')) {
      this.onRequireAuth()
      return
    }
    this.draft = SportRecordService.emptyDraft()
    if (prefillMin > 0) {
      this.draft.durationMin = `${prefillMin}`
    }
    this.formError = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openTemplate(tpl: SportDraft): void {
    if (!AuthService.requireAuth('create')) {
      this.onRequireAuth()
      return
    }
    this.draft = tpl
    this.draft.recordDate = SportRecordService.todayKey()
    this.formError = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private toggleRecording(): void {
    if (!AuthService.requireAuth('create')) {
      this.onRequireAuth()
      return
    }
    if (!this.isRecording) {
      this.isRecording = true
      this.elapsedSec = 0
      this.scheduleTick()
      return
    }
    this.isRecording = false
    const mins = Math.max(1, Math.round(this.elapsedSec / 60))
    this.openForm(mins)
  }

  private scheduleTick(): void {
    if (!this.isRecording) {
      return
    }
    setTimeout(() => {
      if (this.isRecording) {
        this.elapsedSec += 1
        this.scheduleTick()
      }
    }, 1000)
  }

  private formatTimer(sec: number): string {
    const m = Math.floor(sec / 60)
    const s = sec % 60
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`
  }

  private async submitForm(): Promise<void> {
    const res = SportRecordService.create(this.draft)
    if (!res.ok) {
      this.formError = res.message
      return
    }
    await SportStore.save(res.record)
    this.closeForm()
    this.reload()
    this.onDataChanged()
    this.showToast('竞技记录已保存')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          this.TopBanner()
          this.TrainingTipsCard()
          this.RecordingHero()
          if (this.recent !== null) {
            this.RecentCard()
          }
          this.SearchFilterSection()
          Column({ space: Theme.space.s3 }) {
            Text(`历史记录${this.items.length > 0 ? ` · ${this.items.length} 条` : ''}`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.items.length === 0) {
              AppEmpty({
                title: '还没有竞技记录',
                description: '点击下方开始记录，见证每一次进步',
                actionLabel: '手动录入',
                onAction: (): void => {
                  this.openForm(0)
                }
              })
            } else {
              ForEach(this.items, (item: SportRecord) => {
                SportListCard({
                  record: item,
                  onTap: (): void => {
                    SportDetailNav.open(item.id)
                  }
                })
              }, (item: SportRecord) => SportModelClone.recordKey(item))
            }
          }
          .width('100%')
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s6,
          bottom: Theme.space.s10 + 88
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .edgeEffect(EdgeEffect.Spring)
      .onAppear(() => {
        this.reload()
      })

      if (this.showForm) {
        this.RecordFormSheet()
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 18, right: 18, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 52 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TrainingTipsCard() {
    Column({ space: Theme.space.s2 }) {
      Text('录入建议')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('选好体感与天气，后续成长页会自动统计负荷与恢复节奏；复盘字段帮助你对照个人最佳。')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textPrimary)
        .lineHeight(20)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  TopBanner() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_sport_bg'))
        .width('100%')
        .height(160)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column()
        .width('100%')
        .height(160)
        .borderRadius(Theme.radius.xl)
        .linearGradient({
          angle: 180,
          colors: Theme.heroScrim()
        })
      Column({ space: 6 }) {
        Text('TRAINING')
          .fontSize(Theme.type.overline)
          .fontColor(Theme.colors().textOnScrimMuted)
        Text('训练中心')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textOnScrim)
        Text('计时 · 模板 · 搜索筛选 · 复盘一次录全')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textOnScrimMuted)
      }
      .padding(Theme.space.s5)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  SearchFilterSection() {
    GlassPanel() {
      Column({ space: Theme.space.s3 }) {
        SectionHeader({ title: '训练库', subtitle: '按项目、标签或关键词筛选' })
        TextInput({ text: this.searchKeyword, placeholder: '搜索项目、标签、复盘…' })
          .onChange((v: string) => {
            this.searchKeyword = v
            this.items = this.filteredItems()
          })
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textSecondary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.lg)
          .padding({ left: 12, right: 12 })
          .border({ width: 1, color: Theme.colors().strokeHairline })
        Scroll() {
          Row({ space: Theme.space.s2 }) {
            this.FilterChip('全部项目', this.filterSport.length === 0, (): void => {
              this.filterSport = ''
              this.items = this.filteredItems()
            })
            ForEach(SportRecordService.sportTypes(), (t: string) => {
              this.FilterChip(t, this.filterSport === t, (): void => {
                this.filterSport = this.filterSport === t ? '' : t
                this.items = this.filteredItems()
              })
            }, (t: string) => t)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        if (this.tagOptions.length > 0) {
          Scroll() {
            Row({ space: Theme.space.s2 }) {
              this.FilterChip('全部标签', this.filterTag.length === 0, (): void => {
                this.filterTag = ''
                this.items = this.filteredItems()
              })
              ForEach(this.tagOptions, (tag: TagItem) => {
                this.FilterChip(`#${tag.name}`, this.filterTag === tag.name, (): void => {
                  this.filterTag = this.filterTag === tag.name ? '' : tag.name
                  this.items = this.filteredItems()
                })
              }, (tag: TagItem) => tag.name)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }
      }
    }
  }

  @Builder
  FilterChip(label: string, active: boolean, onTap: () => void) {
    SelectChip({
      label: label,
      active: active,
      onTap: onTap
    })
  }

  @Builder
  RecordingHero() {
    GlassPanel() {
      Column({ space: Theme.space.s4 }) {
        Text(this.isRecording ? this.formatTimer(this.elapsedSec) : '一键计时')
          .fontSize(this.isRecording ? Theme.type.displayS : Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
        Text(this.isRecording ? '计时中 · 再次点击结束并保存' : '点击圆环开始，或用手动录入补充数据')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .textAlign(TextAlign.Center)

        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(128)
            .height(128)
            .borderRadius(64)
            .linearGradient({ angle: 135, colors: Theme.brandGradient() })
            .opacity(this.isRecording ? 0.95 : 1)
            .scale({ x: this.isRecording ? 1.05 : 1, y: this.isRecording ? 1.05 : 1 })
            .animation({ duration: 800, iterations: -1, playMode: PlayMode.Alternate })
          Column()
            .width(108)
            .height(108)
            .borderRadius(54)
            .backgroundColor(Theme.isDark() ? 'rgba(7,11,20,0.35)' : 'rgba(255,255,255,0.22)')
          Text(this.isRecording ? '结束' : '开始')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .width(128)
        .height(128)
        .onClick(() => {
          this.toggleRecording()
        })

        AppGradientButton({
          label: '手动录入记录',
          onTap: (): void => {
            this.openForm(0)
          }
        })
        this.TemplateStrip()
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
  }

  @Builder
  RecentCard() {
    Column({ space: Theme.space.s2 }) {
      Text('最近一次')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      if (this.recent !== null) {
        ForEach([this.recent as SportRecord], (item: SportRecord) => {
          SportListCard({
            record: item,
            onTap: (): void => {
              SportDetailNav.open(item.id)
            }
          })
        }, (item: SportRecord) => SportModelClone.recordKey(item))
      }
    }
    .width('100%')
  }

  @Builder
  RecordFormSheet() {
    Column() {
      Column({ space: Theme.space.s4 }) {
        Row() {
          Text('录入竞技数据')
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
            this.SportTypePicker()
            AppDatePickerField({
              label: '运动日期',
              value: this.draft.recordDate,
              onChange: (v: string): void => {
                this.draft.recordDate = v
              }
            })
            this.FieldRow('时长（分钟）', this.draft.durationMin, (v: string): void => {
              this.draft.durationMin = v
            })
            this.FieldRow('距离（公里）', this.draft.distanceKm, (v: string): void => {
              this.draft.distanceKm = v
            })
            this.FieldRow('心率（bpm）', this.draft.heartRate, (v: string): void => {
              this.draft.heartRate = v
            })
            this.FieldRow('消耗（千卡）', this.draft.calories, (v: string): void => {
              this.draft.calories = v
            })
            this.FieldRow('标签', this.draft.tags, (v: string): void => {
              this.draft.tags = v
            }, '如 #晨跑 #力量训练')
            this.FieldRow('本场收获', this.draft.takeaway, (v: string): void => {
              this.draft.takeaway = v
            }, '今天做对了什么')
            this.FieldRow('下次重点', this.draft.nextFocus, (v: string): void => {
              this.draft.nextFocus = v
            }, '下次只改一件事')
            this.FeelingPicker()
            this.WeatherPicker()
            this.FieldRow('备注', this.draft.note, (v: string): void => {
              this.draft.note = v
            }, '其他想记下的细节')
            if (this.formError.length > 0) {
              Text(this.formError)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().danger)
                .width('100%')
            }
            AppButton({
              label: '保存记录',
              onTap: (): void => {
                void this.submitForm()
              }
            })
          }
        }
        .layoutWeight(1)
      }
      .padding(Theme.space.pageX)
      .padding({ top: Theme.space.s6, bottom: Theme.space.s6 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(40)
  }

  @Builder
  TemplateStrip() {
    Column({ space: Theme.space.s2 }) {
      Text('一键套用训练模板')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(SportRecordService.templates(), (d: SportDraft) => {
          Text(SportRecordService.templateLabel(d))
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.openTemplate(d)
            })
        }, (d: SportDraft) => SportRecordService.templateLabel(d))
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  FeelingPicker() {
    Column({ space: Theme.space.s2 }) {
      Text('体感')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(SportRecordService.feelings(), (t: string) => {
          SelectChip({
            label: t,
            active: this.draft.feeling === t,
            onTap: (): void => {
              const next = SportRecordService.cloneDraft(this.draft)
              next.feeling = t
              this.draft = next
            }
          })
            .margin({ right: 8, bottom: 8 })
        }, (t: string) => `feeling_${t}_${this.draft.feeling}`)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  WeatherPicker() {
    Column({ space: Theme.space.s2 }) {
      Text('天气')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(SportRecordService.weathers(), (t: string) => {
          SelectChip({
            label: t,
            active: this.draft.weather === t,
            onTap: (): void => {
              const next = SportRecordService.cloneDraft(this.draft)
              next.weather = t
              this.draft = next
            }
          })
            .margin({ right: 8, bottom: 8 })
        }, (t: string) => `weather_${t}_${this.draft.weather}`)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  SportTypePicker() {
    Column({ space: Theme.space.s2 }) {
      Text('运动类型')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(SportRecordService.sportTypes(), (t: string) => {
          SelectChip({
            label: t,
            active: this.draft.sportType === t,
            onTap: (): void => {
              const next = SportRecordService.cloneDraft(this.draft)
              next.sportType = t
              this.draft = next
            }
          })
            .margin({ right: 8, bottom: 8 })
        }, (t: string) => `type-${t}-${this.draft.sportType}`)
      }
      .width('100%')
    }
    .width('100%')
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
