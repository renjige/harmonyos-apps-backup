import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { ChoiceChip } from '../family/ChoiceChip'
import { FamilyMember, MemberRoleOption } from '../../models/JujiaModels'
import { MemberService } from '../../services/MemberService'

@Component
export struct MembersPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State members: FamilyMember[] = []
  @State name: string = ''
  @State role: string = '家人'
  @State toast: string = ''
  onClose: () => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.members = MemberService.list()
  }

  private async addMember(): Promise<void> {
    if (this.name.trim().length === 0) {
      this.toast = '请填写家人称呼'
      return
    }
    await MemberService.add(this.name, this.role)
    this.name = ''
    this.reload()
    this.onChanged()
    this.toast = '已加入轮值'
  }

  private async removeMember(id: string): Promise<void> {
    await MemberService.remove(id)
    this.reload()
    this.onChanged()
  }

  build() {
    Column() {
      Row() {
        AppIcon({ name: 'close', iconSize: 20, color: Theme.colors().textSecondary })
          .onClick(() => this.onClose())
        Text('家人与轮值')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })

      Scroll() {
        Column({ space: 14 }) {
          Text('添加家人后，看板会按星期轮值倒垃圾、洗碗、浇花，计划也可指定负责人。')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')

          TextInput({ text: this.name, placeholder: '称呼，如：妈妈、爸爸、孩子' })
            .onChange((v: string) => { this.name = v })
            .backgroundColor(Theme.colors().surfaceSubtle)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .placeholderColor(Theme.colors().textTertiary)

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(MemberRoleOption.all(), (r: string) => {
              ChoiceChip({ label: r, active: this.role === r, onPick: () => { this.role = r } })
            }, (r: string) => r)
          }

          AppButton({ label: '加入家庭', variant: 'primary', onTap: () => { void this.addMember() } })

          if (this.members.length === 0) {
            Text('还没有家人。添加后今日轮值会自动出现在看板。')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.members, (m: FamilyMember) => {
              Row() {
                Column({ space: 2 }) {
                  Text(m.name)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(m.role)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                Text('移除')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().danger)
                  .onClick(() => { void this.removeMember(m.id) })
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
            }, (m: FamilyMember) => m.id)
          }

          if (this.toast.length > 0) {
            Text(this.toast)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
          }
        }
        .padding({ left: 16, right: 16, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
