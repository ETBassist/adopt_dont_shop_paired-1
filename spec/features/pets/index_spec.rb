require 'rails_helper'

describe "Pets Index" do
  before (:each) do
    @shelter_1 = Shelter.create!(
      name: "Will's Pet Shelter",
      address: "123 Main St",
      city: "Boulder",
      state: "CO",
      zip: "80309"
    )

    @shelter_2 = Shelter.create!(
      name: "Pet Rescue",
      address: "10 Normal Rd",
      city: "Denver",
      state: "CO",
      zip: "80249"
    )

    @pet_1 = Pet.create!(
      image: "https://placedog.net/280?id=1",
      name: "Max",
      age: "14",
      sex: "Female",
      description: "A nice doggo",
      adoptable: false,
      shelter: @shelter_1
    )

    @pet_2 = Pet.create!(
      image: "https://placedog.net/280?id=2",
      name: "Toby",
      age: "7",
      sex: "Male",
      description: "A nice doggo",
      adoptable: true,
      shelter: @shelter_2
    )
  end

  describe "When I visit /pets" do
    it "I see each pet and their info" do
      visit '/pets'

      expect(page).to have_xpath("//img[contains(@src,'#{@pet_1.image}')]")
      expect(page).to have_content(@pet_1.name)
      expect(page).to have_content(@pet_1.age)
      expect(page).to have_content(@pet_1.sex)
      expect(page).to have_content(@pet_1.shelter.name)

      expect(page).to have_xpath("//img[contains(@src,'#{@pet_2.image}')]")
      expect(page).to have_content(@pet_2.name)
      expect(page).to have_content(@pet_2.age)
      expect(page).to have_content(@pet_2.sex)
      expect(page).to have_content(@pet_2.shelter.name)
    end

    it 'I see a count of pets' do
      visit "/pets"
      expect(page).to have_content('Total pets: 2')
    end

    it 'I see adoptable pets listed before pending' do
      visit "/pets"
      expect(@pet_2.name). to appear_before(@pet_1.name)
    end

    it 'I see filter by adoption status' do
      visit "/pets"

      click_link 'Adoptable Pets'

      expect(page).to have_content(@pet_2.name)
      expect(page).to_not have_content(@pet_1.name)

      click_link 'Pets Pending Adoption'

      expect(page).to_not have_content(@pet_2.name)
      expect(page).to have_content(@pet_1.name)
    end

    it 'I do not see pets from a deleted shelter' do
      visit "/shelters/#{@shelter_1.id}"

      click_on "Delete Shelter"

      visit '/pets'

      expect(page).to_not have_content(@shelter_1.name)
      expect(page).to_not have_content(@pet_1.name)
    end

    it "I cannot delete a pet with an approved application" do
      pet = create(:pet)
      application = create(:application, status: "Approved")
      pet_app = create(:pet_application, pet: pet, application: application)

      visit '/pets'

      within("#pet-#{pet.id}") do
        expect(page).to_not have_link('Delete Pet')
        expect(page).to have_content('Delete Pet')
      end
    end

    it 'I see section of pets with approved applications' do
      adopted_pet1 = create(:pet, name: 'Greta', shelter: @shelter_2, adoptable: false)
      adopted_pet2 = create(:pet, name: 'Hans', shelter: @shelter_2, adoptable: false)
      app_approved = create(:application, status: 'Approved')
      app_unapproved = create(:application, status: 'Pending')
      pet_app_approved = create(:pet_application, pet: adopted_pet1, application: app_approved)
      pet_app = create(:pet_application, pet: adopted_pet2, application: app_unapproved)

      visit "/pets"

      expect(page).to have_content('Adopted Pets')
      within('.adopted-pets') do
        expect(page).to have_content(adopted_pet1.name)
        expect(page).to_not have_content(adopted_pet2.name)
      end
    end
  end
end
