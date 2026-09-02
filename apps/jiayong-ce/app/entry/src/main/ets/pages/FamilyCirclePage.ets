import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { Anniversary, FamilyActivity, FamilyMember } from '../models/AlbumModels'
import { AlbumStore } from '../services/AlbumStore'
import { AlbumNav } from '../services/AlbumNav'

@Component
export struct FamilyCirclePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('albumRev') @Watch('onAlbumRev') storeRev: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onToast: (text: string) => void = (text: string) => {}

  @State members: FamilyMember[] = []
  @State activities: FamilyActivity[] = []
  @State days: Anniversary[] = []
  @State inviteCode: string = ''
  @State newMemberName: string = ''
  @State newMemberRelation: string = '家人'
  @State showAddMember: boolean = false
  @State showAddDay: boolean = false
  @State dayTitle: string = ''
  @State dayMonth: string = ''
  @State dayDay: string = ''
  @State dayNote: string = ''
  @State confirmDayId: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  onAlbumRev(): void {
    this.reload()
  }

  private reload(): void {
    this.members = AlbumStore.members()
    this.activities = AlbumStore.activities()
    this.days = AlbumStore.anniversaries()
    this.inviteCode = AlbumStore.profile().inviteCode
  }

  private memberCount(id: string): number {
    return AlbumStore.byMember(id).length
  }

  private copyInvite(): void {
    this.onToast(`邀请链接：${AlbumStore.inviteLink()}（请手动分享）`)
  }

  private async addMember(): Promise<void> {
    if (this.newMemberName.trim().length === 0) {
      this.onToast('请输入成员姓名')
      return
    }
    const ok = await AlbumStore.addMember(this.newMemberName, this.newMemberRelation)
    if (!ok) {
      this.onToast('添加失败，请稍后再试')
      return
    }
    this.newMemberName = ''
    this.showAddMember = false
    this.reload()
    this.onToast('成员已添加，上传时可按人物分册')
  }

  private async addDay(): Promise<void> {
    const month = Number.parseInt(this.dayMonth, 10)
    const day = Number.parseInt(this.dayDay, 10)
    const ok = await AlbumStore.addAnniversary(this.dayTitle, month, day, this.dayNote)
    if (!ok) {
      this.onToast('请填写纪念日名称，并输入有效月/日')
      return
    }
    this.dayTitle = ''
    this.dayMonth = ''
    this.dayDay = ''
    this.dayNote = ''
    this.showAddDay = false
    this.reload()
    this.onToast('纪念日已添加，首页会在当月提醒')
  }

  private async removeDay(id: string): Promise<void> {
    if (this.confirmDayId !== id) {
      this.confirmDayId = id
      this.onToast('再点一次确认删除纪念日')
      return
    }
    const ok = await AlbumStore.deleteAnniversary(id)
    this.confirmDayId = ''
    if (!ok) {
      this.onToast('删除失败')
      return
    }
    this.reload()
    this.onToast('纪念日已删除')
  }

  private activityTime(ts: number): string {
    const d = new Date(ts)
    return `${d.getMonth() + 1}月${d.getDate()}日 ${d.getHours()}:${d.getMinutes() < 10 ? '0' + d.getMinutes() : d.getMinutes()}`
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Image($r('app.media.banner_01'))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.card)
            .margin({ bottom: Theme.space.s4 })

          Row() {
            Text('家庭成员')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('添加')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .height(48)
              .onClick((): void => { this.showAddMember = !this.showAddMember })
          }
          .width('100%')

          if (this.showAddMember) {
            Column() {
              TextInput({ text: this.newMemberName, placeholder: '姓名' })
                .onChange((v: string) => { this.newMemberName = v })
                .margin({ bottom: Theme.space.s2 })
              TextInput({ text: this.newMemberRelation, placeholder: '关系，如爸爸/妈妈' })
                .onChange((v: string) => { this.newMemberRelation = v })
              AppButton({ label: '保存成员', onTap: (): void => { void this.addMember() } })
                .margin({ top: Theme.space.s3 })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .margin({ top: Theme.space.s3 })
          }

          ForEach(this.members, (m: FamilyMember) => {
            Row() {
              Column() {
                Text(m.name.length > 0 ? m.name.substring(0, 1) : '?')
                  .fontColor('#FFFFFF')
                  .fontSize(Theme.type.subhead)
              }
              .width(40)
              .height(40)
              .borderRadius(20)
              .backgroundColor(m.avatarColor)
              .justifyContent(FlexAlign.Center)
              Column() {
                Text(m.name)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(`${m.relation} · ${this.memberCount(m.id)} 张照片`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: Theme.space.s3 })
              .layoutWeight(1)
              if (m.isOwner) {
                Text('管理员')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              }
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .margin({ top: Theme.space.s2 })
            .onClick((): void => { AlbumNav.openFilter('people', m.id) })
          }, (m: FamilyMember) => m.id)

          Row() {
            Text('家庭纪念日')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('添加')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .height(48)
              .onClick((): void => { this.showAddDay = !this.showAddDay })
          }
          .width('100%')
          .margin({ top: Theme.space.s6 })

          if (this.showAddDay) {
            Column() {
              TextInput({ text: this.dayTitle, placeholder: '如：结婚纪念日' })
                .onChange((v: string) => { this.dayTitle = v })
                .margin({ bottom: Theme.space.s2 })
              TextInput({ text: this.dayMonth, placeholder: '月份 1-12' })
                .onChange((v: string) => { this.dayMonth = v })
                .margin({ bottom: Theme.space.s2 })
              TextInput({ text: this.dayDay, placeholder: '日期 1-31' })
                .onChange((v: string) => { this.dayDay = v })
                .margin({ bottom: Theme.space.s2 })
              TextInput({ text: this.dayNote, placeholder: '备注（可选）' })
                .onChange((v: string) => { this.dayNote = v })
              AppButton({ label: '保存纪念日', onTap: (): void => { void this.addDay() } })
                .margin({ top: Theme.space.s3 })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .margin({ bottom: Theme.space.s2 })
          }

          if (this.days.length === 0) {
            Text('记录生日、结婚日等，首页当月会提醒')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.days, (a: Anniversary) => {
              Row() {
                Column() {
                  Text(a.title)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(`${a.month}月${a.day}日${a.note.length > 0 ? ' · ' + a.note : ''}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                Text(this.confirmDayId === a.id ? '确认删' : '删除')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().danger : Theme.colors().danger)
                  .height(48)
                  .onClick((): void => { void this.removeDay(a.id) })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .margin({ bottom: Theme.space.s2 })
            }, (a: Anniversary) => a.id)
          }

          Column() {
            Text('邀请加入家庭')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(`邀请码：${this.inviteCode}`)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .margin({ top: Theme.space.s2 })
            Text('家人可通过邀请链接加入同一家庭空间（本机演示）')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .margin({ top: Theme.space.s2 })
            AppButton({ label: '复制邀请链接', variant: 'secondary', onTap: (): void => { this.copyInvite() } })
              .margin({ top: Theme.space.s3 })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
          .margin({ top: Theme.space.s6 })

          Text('家庭动态')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .margin({ top: Theme.space.s6, bottom: Theme.space.s3 })

          if (this.activities.length === 0) {
            Text('上传照片后，家人动态会出现在这里')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.activities, (a: FamilyActivity) => {
              Row() {
                AppIcon({ name: 'photo', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
                Column() {
                  Text(`${a.memberName} ${a.caption}`)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(this.activityTime(a.createdAt))
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: Theme.space.s3 })
                .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .margin({ bottom: Theme.space.s2 })
              .onClick((): void => {
                if (a.photoId.length > 0) {
                  AlbumNav.openDetail(a.photoId)
                }
              })
            }, (a: FamilyActivity) => a.id)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
